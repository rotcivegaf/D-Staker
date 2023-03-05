export const ERC20_ABI = [
	'function symbol() view returns (string)',
	'function balanceOf(address) view returns (uint)',
	'function transfer(address to, uint amount)'
];

export const STAKING_POOL_ABI = [
	'function stake() payable',
	'function claim()',
	'function unstake(uint256)',

	'function symbol() view returns (string)',
	'function balanceOf(address) view returns (uint)',
	'function transfer(address to, uint amount)',

	'function totalSupply() view returns(uint256)',
	'function totalValidators() view returns(uint256)',
	'function totalEarned() view returns (uint256)',
	'function totalEarnedHistoric() view returns (uint256)',
	'function totalEarnedHistoricInUSD() view returns (uint256)',
	'function totalEarnedInUSD() view returns (uint256)',
	'function totalAssets() view returns (uint256)',
	'function totalAssetsInUSD() view returns (uint256)',
	'function stakeOf(address) view returns (uint256)',
	'function stakeOfInUSD(address) view returns (uint256)',
	'function calcRewards(address) view returns (uint256)',
	'function calcRewardsInUSD(address) view returns (uint256)'
];
