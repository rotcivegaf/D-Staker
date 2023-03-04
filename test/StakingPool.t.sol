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
    address alice;

    StakingPool private stakingPool;

    function setUp() external {
        alice = address(1);

        address depositContractAddress = 0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b;
        address SSVTokenAddress = 0x3a9f01091C446bdE031E39ea8354647AFef091E7;
        address SSVNetworkAddress = 0xb9e155e65B5c4D66df28Da8E9a0957f06F11Bc04;
        address SSVRegistryAddress = 0x49D395eFcE6233e116C69333F249e6cF128D5992;
        address wethAddress = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
        address priceFeedAddress = 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e;

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

    function testStake() external {
        vm.startPrank(alice);

        stakingPool.stake{value: 1 ether}();

        assertEq(weth.balanceOf(address(stakingPool)), 1 ether, "bad weth balance");
        assertEq(stakingPool.balanceOf(alice), 1 ether, "bad stakingPool balance");

        stakingPool.stake{value: 32 ether}();

        assertEq(weth.balanceOf(address(stakingPool)),33 ether, "bad weth balance");
        assertEq(stakingPool.balanceOf(alice), 33 ether, "bad stakingPool balance");
    }

    function testCalcRewards() external {
        vm.startPrank(alice);

        vm.expectRevert();
        stakingPool.calcRewards(alice);

        stakingPool.stake{value: 1 ether}();

        assertEq(stakingPool.calcRewards(alice), 0);

        deal(address(stakingPool), 1 ether);

        assertEq(stakingPool.calcRewards(alice), 0);
    }

    function testUnstake() external {
        vm.startPrank(alice);

        stakingPool.stake{value: 1 ether}();

        stakingPool.unstake(1 ether);

        assertEq(weth.balanceOf(address(stakingPool)), 0, "bad weth balance");
        assertEq(stakingPool.balanceOf(alice), 0, "bad stakingPool balance");
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
