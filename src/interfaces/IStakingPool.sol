// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Validator} from "../StakingPool.sol";

interface IStakingPool {
    function validator(bytes32 pubSigHash) external returns (Validator memory);

    function stake() external payable;

    function unstake(uint256 amount) external;

    function claim() external;

    function registerValidator(
        bytes calldata pubKey,
        uint32[] calldata operatorIds,
        bytes[] calldata sharesPublicKeys,
        bytes[] calldata sharesEncrypted,
        uint256 amount
    ) external;

    function removeValidator(bytes calldata pubKey) external;

    function depositValidatorStaking(
        bytes calldata pubKey,
        bytes calldata withdrawal_credentials,
        bytes calldata signature,
        bytes32 deposit_data_root
    ) external;

    function getLatestPrice() external view returns (int256);
}
