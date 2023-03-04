// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "src/StakingPool.sol";

contract AddRewardsScript is Script {
    StakingPool private stakingPool;

    function setUp() public {}

    function run() public {
        address stakingPoolAddress = vm.envAddress("SCA");

        uint256 amount = vm.envUint("AMOUNT");

        stakingPool = StakingPool(payable(stakingPoolAddress));

        vm.startBroadcast();

        address(stakingPool).call{value: amount * 1 ether}("");

        vm.stopBroadcast();
    }
}
