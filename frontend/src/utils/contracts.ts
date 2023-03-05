import { STAKING_POOL_ABI, ERC20_ABI } from './abis.js';

import { get } from 'svelte/store';

import { Contract } from '@ethersproject/contracts';
import { signer, provider } from '../store/wallet';

const contractsDictionary: Array<Contract> = [];
const contractsReadOnlyDictionary: Array<Contract> = [];

export async function getWETHContract() {
	return await getContract(import.meta.env.VITE_WETH_ADDRESS, ERC20_ABI);
}

export async function getStakingPoolContract() {
	return await getContract(import.meta.env.VITE_STAKING_POOL_ADDRESS, STAKING_POOL_ABI);
}

export async function getContract(address: any, abi: any) {
	const _signer = await get(signer);
	const _provider = await get(provider);

	if (!_signer || !_provider) {
		throw new Error('Error');
	}

	if (_signer) {
		if (!contractsDictionary[address]) {
			contractsDictionary[address] = new Contract(address, abi, _signer);
		}

		return contractsDictionary[address];
	}

	if (_provider) {
		if (!contractsReadOnlyDictionary[address]) {
			contractsReadOnlyDictionary[address] = new Contract(address, abi, _provider);
		}
		return contractsReadOnlyDictionary[address];
	}
}
