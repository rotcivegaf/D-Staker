<script lang="ts">
	import {address} from "$store/wallet";
	import {getStakingPoolContract} from '$utils/contracts';
	import {showNotification, NotificationType} from '$store/notifications';
	import {BigNumber, utils} from 'ethers';

	let stakingPoolContract;
	
	let totalEarned = BigNumber.from(0);
	let totalEarnedInUSD = BigNumber.from(0);
	let totalStaked = BigNumber.from(0);
	let totalStakedInUSD = BigNumber.from(0);
	let totalValidators = BigNumber.from(0);

	let loading = false;

	async function load() {
		stakingPoolContract = await getStakingPoolContract();

		if (!stakingPoolContract) {
			showNotification("Success", {
				type: NotificationType.Error
			});
			return;
		}

		[totalEarned, totalEarnedInUSD, totalStaked, totalStakedInUSD, totalValidators] = await Promise.all([
				stakingPoolContract.totalEarned(),
				stakingPoolContract.totalEarnedInUSD(),
				stakingPoolContract.totalSupply(),
				stakingPoolContract.totalAssetsInUSD(),			
				stakingPoolContract.totalValidators(),
		]);

		loading = false;
	}

	$: if($address) {
    load();
  }
</script>

<svelte:head>
	<title>D-Staker! - Ethereum stake service</title>
	<meta name="description" content="D-Staker! - Ethereum stake service" />
</svelte:head>

<div
	class="hero min-h-screen"
	style="background-image: url(/hero.jpg);"
>
	<div class="hero-overlay bg-opacity-30" />
	<div class="hero-content text-center text-neutral-content">
		<div class="max-w-md">
			<h1 class="mb-5 text-6xl font-bold">D-Staker!</h1>
			<p class="mb-5">
				Stake ETH, contribute on Ethereum and earn rewards with low risks!
			</p>
			<a class="btn btn-primary" href="/stake">Get Started</a>
		</div>
	</div>
</div>

<div class="w-full p-10 bg-slate-100">
	<div class="flex flex-row justify-around w-full my-5">
		<div class="flex flex-col justify-center">
			<p class="text-2xl font-bold  text-center">
				{utils.formatEther(totalStaked)} ETH
			</p>
			<p class="text-center text-xs">${parseFloat(utils.formatEther(totalStakedInUSD)).toFixed(2)} USD</p>
			<p class="uppercase text-center font-bold">
				Total staked
			</p>
		</div>
		<div class="flex flex-col justify-center">
			<p class="text-2xl font-bold  text-center">
				{totalValidators}
			</p>
			<p class="uppercase text-center font-bold">Validators</p>
		</div>
		<div class="flex flex-col justify-center">
			<p class="text-2xl font-bold  text-center">
				{utils.formatEther(totalEarned)} ETH
			</p>
			<p class="text-center text-xs">${parseFloat(utils.formatEther(totalEarnedInUSD)).toFixed(2)} USD</p>
			<p class="uppercase text-center font-bold">rewards earned</p>
		</div>
	</div>
</div>