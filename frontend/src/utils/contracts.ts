import { STAKING_POOL_ABI } from './abis.js';

import { get } from 'svelte/store';

import { Contract } from '@ethersproject/contracts';
import { signer, provider } from '../store/wallet';

const contractsDictionary: Array<Contract> = [];
const contractsReadOnlyDictionary: Array<Contract> = [];

export async function getStakingPoolContract() {
	const _signer = await get(signer);
	const _provider = await get(provider);

	if (!_signer || !_provider) {
		throw new Error('Error');
	}

	const stakingPoolAddress = import.meta.env.VITE_STAKING_POOL_ADDRESS;

	if (_signer) {
		if (!contractsDictionary[stakingPoolAddress]) {
			contractsDictionary[stakingPoolAddress] = new Contract(
				stakingPoolAddress,
				STAKING_POOL_ABI,
				_signer
			);
		}

		return contractsDictionary[stakingPoolAddress];
	}

	if (_provider) {
		if (!contractsReadOnlyDictionary[stakingPoolAddress]) {
			contractsReadOnlyDictionary[stakingPoolAddress] = new Contract(
				stakingPoolAddress,
				STAKING_POOL_ABI,
				_provider
			);
		}
		return contractsReadOnlyDictionary[stakingPoolAddress];
	}
}
