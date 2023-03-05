// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import {ERC4626} from "solmate/mixins/ERC4626.sol";
import {Owned} from "solmate/auth/Owned.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {SafeTransferLib} from "solmate/utils/SafeTransferLib.sol";
import {WETH} from "solmate/tokens/WETH.sol";

import {ISSVNetwork} from "ssv-network/ISSVNetwork.sol";
import {ISSVRegistry} from "ssv-network/ISSVRegistry.sol";

import {IDepositContract} from "./interfaces/IDepositContract.sol";

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

enum IsActive {
    NONE,
    FALSE,
    TRUE
}

struct Validator {
    bytes pubkey;
    uint32[] operatorIds;
    bytes[] sharesPublicKeys;
    bytes[] sharesEncrypted;
    uint256 amount;
    IsActive active;
}

contract StakingPool is Owned, ERC4626 {
    uint256 private constant VALIDATOR_STAKE_AMOUNT = 32 ether;

    mapping(bytes32 => Validator) public validators;
    mapping(address => uint256) public userClaims;
    uint256 public totalValidators;
    uint256 public totalEarned;
    uint256 public totalEarnedHistoric;

    IDepositContract public immutable depositContract;
    ISSVNetwork public immutable SSVNetwork;
    ISSVRegistry public immutable SSVRegistry;
    ERC20 public immutable SSVToken;
    AggregatorV3Interface internal immutable priceFeed;

    /* EVENTS */
    event ValidatorRegistered(bytes32 pubKeyHash, uint256 timestamp);
    event ValidatorRemoved(bytes32 pubKeyHash, uint256 timestamp);
    event ValidatorStakeDeposited(bytes32 pubKeyHash, uint256 timestamp);
    event StakeReached(uint256 stakeCount);

    event RewardIndexUpdated(
        address indexed from,
        uint256 reward,
        uint256 timestamp
    );
    event Staked(address indexed from, uint256 amount, uint256 timestamp);
    event Unstaked(address indexed from, uint256 amount, uint256 timestamp);
    event Claimed(address indexed from, uint256 amount, uint256 timestamp);

    /* ERRORS */
    error InvalidAmount();
    error ValidatorAlreadyExists(bytes32 pubKeyHash, uint256 timestamp);

    constructor(
        IDepositContract _depositContract,
        ERC20 _SSVToken,
        ISSVNetwork _SSVNetwork,
        ISSVRegistry _SSVRegistry,
        ERC20 _weth,
        AggregatorV3Interface _priceFeedAddress
    ) Owned(msg.sender) ERC4626(_weth, "pool SSV token", "PSSV") {
        depositContract = _depositContract;
        SSVToken = _SSVToken;
        SSVRegistry = _SSVRegistry;
        SSVNetwork = _SSVNetwork;
        priceFeed = _priceFeedAddress;
    }

    receive() external payable {
        if (address(asset) != msg.sender) {
            totalEarned += msg.value;
            totalEarnedHistoric += msg.value;
        }
    }

    function stake() public payable {
        if (msg.value == 0) {
            revert InvalidAmount();
        }

        WETH(payable(address(asset))).deposit{value: msg.value}();

        _calculateAssets(msg.value);
    }

    function stake(uint256 amount) public {
        if (amount == 0) {
            revert InvalidAmount();
        }

        asset.transferFrom(msg.sender, address(this), amount);

        _calculateAssets(amount);
    }

    function _calculateAssets(uint256 _amount) internal {
        uint256 cBalance = asset.balanceOf(address(this));
        uint256 stakes = (cBalance - _amount) / VALIDATOR_STAKE_AMOUNT;
        uint256 remainder = cBalance - stakes * VALIDATOR_STAKE_AMOUNT;

        if (remainder >= VALIDATOR_STAKE_AMOUNT) {
            emit StakeReached(remainder / VALIDATOR_STAKE_AMOUNT);
        }

        _mint(msg.sender, _amount);

        emit Staked(msg.sender, _amount, block.timestamp);
    }

    function unstake(uint256 _amount) external {
        _claim();
        _burn(msg.sender, _amount);

        asset.transferFrom(address(this), msg.sender, _amount);

        emit Unstaked(msg.sender, _amount, block.timestamp);
    }

    function claim() external {
        _claim();
    }

    function _claim() internal {
        uint256 amount = calcRewards(msg.sender);

        if (amount == 0) {
            return;
        }

        totalEarned -= amount;
        userClaims[msg.sender] += amount;
        payable(msg.sender).transfer(amount);

        emit Claimed(msg.sender, amount, block.timestamp);
    }

    function registerValidatorAndDeposit(
        bytes memory pubKey,
        uint32[] memory operatorIds,
        bytes[] memory sharesPublicKeys,
        bytes[] memory sharesEncrypted,
        uint256 amount,
        bytes memory withdrawal_credentials,
        bytes memory signature,
        bytes32 deposit_data_root
    ) external onlyOwner {
        registerValidator(
            pubKey,
            operatorIds,
            sharesPublicKeys,
            sharesEncrypted,
            amount
        );

        depositValidatorStaking(
            pubKey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );
    }

    function registerValidator(
        bytes memory pubKey,
        uint32[] memory operatorIds,
        bytes[] memory sharesPublicKeys,
        bytes[] memory sharesEncrypted,
        uint256 amount
    ) public onlyOwner {
        bytes32 pubKeyHash = keccak256(pubKey);

        if (validators[pubKeyHash].active == IsActive.TRUE) {
            revert ValidatorAlreadyExists(pubKeyHash, block.timestamp);
        }

        SSVToken.approve(address(SSVNetwork), amount);

        // Register the validator and deposit the shares
        SSVNetwork.registerValidator(
            pubKey,
            operatorIds,
            sharesPublicKeys,
            sharesEncrypted,
            amount
        );

        validators[pubKeyHash] = Validator(
            pubKey,
            operatorIds,
            sharesPublicKeys,
            sharesEncrypted,
            amount,
            IsActive.TRUE
        );

        unchecked {
            totalValidators = totalValidators + 1;
        }

        // Emit an event to log the deposit of shares
        emit ValidatorRegistered(pubKeyHash, block.timestamp);
    }

    function removeValidator(bytes calldata pubKey) external onlyOwner {
        bytes32 pubKeyHash = keccak256(pubKey);

        if (validators[pubKeyHash].active == IsActive.FALSE) {
            revert ValidatorAlreadyExists(pubKeyHash, block.timestamp);
        }

        SSVNetwork.removeValidator(pubKey);

        delete validators[pubKeyHash];

        emit ValidatorRemoved(pubKeyHash, block.timestamp);
    }

    function depositValidatorStaking(
        bytes memory pubKey,
        bytes memory withdrawal_credentials,
        bytes memory signature,
        bytes32 deposit_data_root
    ) public onlyOwner {
        WETH(payable(address(asset))).withdraw(VALIDATOR_STAKE_AMOUNT);
        // Deposit the validator to the deposit contract
        depositContract.deposit{value: VALIDATOR_STAKE_AMOUNT}(
            pubKey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );
        // Emit an event to log the deposit of the public key
        emit ValidatorStakeDeposited(keccak256(pubKey), block.timestamp);
    }

    function totalAssets() public view override returns (uint256) {
        return asset.balanceOf(address(this));
    }

    function totalAssetsInUSD() public view returns (uint256) {
        (uint256 price, uint256 priceDecimals) = getLatestPrice();
        return (totalSupply * price) / priceDecimals;
    }

    function stakeOf(address who) external view returns (uint256 amount) {
        return balanceOf[who];
    }

    function stakeOfInUSD(address who) external view returns (uint256 amount) {
        (uint256 price, uint256 priceDecimals) = getLatestPrice();
        return (balanceOf[who] * price) / priceDecimals;
    }

    function totalEarnedInUSD() external view returns (uint256 amount) {
        (uint256 price, uint256 priceDecimals) = getLatestPrice();
        return (totalEarned * price) / priceDecimals;
    }

    function totalEarnedHistoricInUSD() external view returns (uint256 amount) {
        (uint256 price, uint256 priceDecimals) = getLatestPrice();
        return (totalEarnedHistoric * price) / priceDecimals;
    }

    function calcRewards(address who) public view returns (uint256 amount) {
        uint256 percSender = (balanceOf[who] * 1000) / totalSupply;

        amount = (percSender * totalEarned) / 1000;
        uint256 userClaim = userClaims[msg.sender];

        if (amount > userClaim) {
            amount -= userClaim;
        } else {
            return 0;
        }
    }

    function calcRewardsInUSD(address who)
        external
        view
        returns (uint256 amount)
    {
        (uint256 price, uint256 priceDecimals) = getLatestPrice();
        return (calcRewards(who) * price) / priceDecimals;
    }

    function getLatestPrice()
        public
        view
        returns (uint256 price, uint256 priceDecimals)
    {
        (, int256 inputPrice, , , ) = priceFeed.latestRoundData();
        require(inputPrice > 0, "Bad price");

        price = uint256(inputPrice);

        priceDecimals = 1 * 10**priceFeed.decimals();
    }

    // Removed functions

    function deposit(uint256, address) public pure override returns (uint256) {
        revert("Can't deposit");
    }

    function mint(uint256, address) public pure override returns (uint256) {
        revert("Can't mint");
    }

    function withdraw(
        uint256,
        address,
        address
    ) public pure override returns (uint256) {
        revert("Can't withdraw");
    }

    function redeem(
        uint256,
        address,
        address
    ) public pure override returns (uint256) {
        revert("Can't redeem");
    }
}
