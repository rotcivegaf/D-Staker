// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import "forge-std/console.sol";

import {ISSVNetwork} from "ssv-network/ISSVNetwork.sol";
import {ISSVRegistry} from "ssv-network/ISSVRegistry.sol";

import {IDepositContract} from "src/interfaces/IDepositContract.sol";

import "src/StakingPool.sol";

import {StakingDataMock} from "./mocks/StakingDataMock.sol";

contract StakingPoolTest is Test, StakingDataMock {
    IDepositContract private depositContract;
    ISSVNetwork private ssvNetwork;
    ISSVRegistry private ssvRegistry;
    ERC20 private ssvToken;
    WETH private weth;

    StakingPool private stakingPool;

    function setUp() external {
        address depositContractAddress = vm.envAddress(
            "DEPOSIT_CONTRACT_ADDRESS"
        );
        address SSVTokenAddress = vm.envAddress("SSV_TOKEN_ADDRESS");
        address SSVNetworkAddress = vm.envAddress("SSV_NETWORK_ADDRESS");
        address SSVRegistryAddress = vm.envAddress("SSV_REGISTRY_ADDRESS");
        address wethAddress = vm.envAddress("WETH_ADDRESS");
        address priceFeedAddress = vm.envAddress("ETH_USD_PRICE_FEED_ADDRESS");

        depositContract = IDepositContract(depositContractAddress);
        ssvToken = ERC20(SSVTokenAddress);
        ssvNetwork = ISSVNetwork(SSVNetworkAddress);
        ssvRegistry = ISSVRegistry(SSVRegistryAddress);
        weth = WETH(payable(wethAddress));
        AggregatorV3Interface priceFeed = AggregatorV3Interface(
            priceFeedAddress
        );

        stakingPool = new StakingPool(
            depositContract,
            ssvToken,
            ssvNetwork,
            ssvRegistry,
            weth,
            priceFeed
        );

        vm.label(depositContractAddress, "DepositContract");
        vm.label(SSVTokenAddress, "SSVToken");
        vm.label(SSVNetworkAddress, "SSVNetwork");
        vm.label(SSVRegistryAddress, "SSVRegistryAddress");
        vm.label(address(this), "owner");

        deal(SSVTokenAddress, address(stakingPool), 100 ether);
    }

    function testStakingPool() external {
        address bob = makeAddr("bob");
        deal(bob, 100 ether);

        vm.prank(bob);
        stakingPool.stake{value: 32 ether}();

        stakingPool.depositValidatorStaking(
            pubKey,
            withdrawal_credentials,
            signature,
            deposit_data_root
        );

        uint256 amount = 10 ether;

        stakingPool.registerValidator(
            pubKey,
            operatorIds,
            sharesPublicKeys,
            sharesEncrypted,
            amount
        );
    }
}
