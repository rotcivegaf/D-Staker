// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.17;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "src/StakingPool.sol";

contract ClaimScript is Script {
    StakingPool private stakingPool;

    function setUp() public {}

    function run() public {
        address stakingPoolAddress = vm.envAddress("SCA");

        stakingPool = StakingPool(payable(stakingPoolAddress));

        vm.startBroadcast();

        stakingPool.claim();

        vm.stopBroadcast();
    }
}
