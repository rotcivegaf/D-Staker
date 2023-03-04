import { chains, type Chain } from 'eth-chains';

type NativeCurrency = {
	name: string;
	symbol: string;
	decimals: number;
};

type CreateNewNetworkData = {
	chainId: string;
	chainName: string;
	nativeCurrency: NativeCurrency;
	rpcUrls: string[];
	blockExplorerUrls: string[];
};

export function getNetworkByChainId(chainId: number): Chain {
	const network = chains.getById(chainId);
	if (!network) {
		throw new Error('invalid chain id');
	}
	return network;
}

export function getCreateNetworkDataByChainId(chainId: number): CreateNewNetworkData {
	const network = getNetworkByChainId(chainId);
	const { name, nativeCurrency, rpc, explorers, infoURL } = network;
	return {
		chainId: `0x${chainId.toString(16)}`,
		chainName: name,
		nativeCurrency,
		rpcUrls: rpc,
		blockExplorerUrls: [
			explorers && explorers.length > 0 && explorers[0].url ? explorers[0].url : infoURL
		]
	};
}
