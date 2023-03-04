<script lang="ts">
	import {getStakingPoolContract} from "$utils/contracts";
	import {signer, address, provider} from "$store/wallet";
	import {showNotification, NotificationType} from "$store/notifications";
	import {BigNumber, utils, Contract} from 'ethers';
	import {simulate} from '$utils/simulator';
	
	const {formatEther} = utils;

	let loading = false;
	let stakingContract: Contract | undefined; 

	let symbol: string = '';
	let totalEarned = BigNumber.from(0);
	let totalEarnedInUSD = BigNumber.from(0);
	let totalStaked = BigNumber.from(0);
	let totalStakedInUSD = BigNumber.from(0);

	async function load() {
		loading = true;

		if (!$provider || !$address) {
			return;
		}

		stakingContract = await getStakingPoolContract();

		if (!stakingContract) {
			showNotification("Invalid Staking Pool Contract", {
				type: NotificationType.Error
			});
			return;
		}

		[totalEarned, totalEarnedInUSD, totalStaked, totalStakedInUSD, symbol] = await Promise.all([
			stakingContract.calcRewards($address),
			stakingContract.calcRewardsInUSD($address),
			stakingContract.stakeOf($address),
			stakingContract.stakeOfInUSD($address),
			stakingContract.symbol(),
		]);
	}

	let claming = false;
	async function claim() {
		if (!stakingContract) {
			showNotification("Invalid Staking Pool Contract", {
				type: NotificationType.Error
			});
			return;
		}
		claming = true;
		try {
			// const rawTransaction = await stakingContract.populateTransaction.claim();
			// const successfull = await simulate(rawTransaction);
			// if (!successfull) {
			// 	showNotification("The transaction will be reverted. Please, check the values", {
			// 		type: NotificationType.Error
			// 	});
			// 	return;
			// }
			const tx = await stakingContract.claim();
			const receipt = await tx.wait();
			console.log(receipt);
			showNotification("Success", {
				type: NotificationType.Check
			});
		} catch (error) {
			console.error(error);
			showNotification(error.message, {
				type: NotificationType.Error
			});
		}
		claming = false;
	}

	let unstaking = false;
	async function unstake() {
		if (!stakingContract) {
			throw new Error('invalid contract');
		}
		unstaking = true;
		try {
			const rawTransaction = await stakingContract.populateTransaction.unstake(totalStaked);
			const successfull = await simulate(rawTransaction);
			if (!successfull) {
				showNotification("The transaction will be reverted. Please, check the values", {
					type: NotificationType.Error
				});
				return;
			}
			const tx = await stakingContract.unstake(totalStaked);
			const receipt = await tx.wait();
			console.log(receipt);
			showNotification("Success", {
				type: NotificationType.Check
			});
		} catch (error) {
			console.error(error);
			showNotification(error.message, {
				type: NotificationType.Error
			});
		}
		unstaking = false;
	}

	$: if ($signer) {
		load();
	}

	$: if ($address) {
		load();
	}
</script>

<svelte:head>
	<title>Dashboard</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<div class="min-h-screen bg-base-200 flex flex-col w-full items-center py-10">
	<div class="flex flex-col my-5">
		<h1 class="text-5xl">Dashboard</h1>
	</div>
	<div class="flex flex-row">
		<div class="flex flex-col items-center lg:text-left border-2 py-10 px-5 m-2">
			<h2 class="text-3xl font-bold text-center">Total Staked</h2>
			<p class="py-6">
				This is how much ethere you have staked in the platform
			</p>
			<div class="flex flex-col justify-stretch">
				{#if totalStaked.gt(0)}
					<h3 class="font-bold text-2xl text-center">{formatEther(totalStaked)} ETH</h3>
					<h4 class="text-center">${parseFloat(utils.formatEther(totalStakedInUSD)).toFixed(2)} USD</h4>
					<button 
						class="btn btn-primary btn-wide mt-5"
						class:disabled={totalStaked.eq(0)}
						class:loading={unstaking}
						disabled={totalStaked.eq(0) || unstaking}
						on:click={unstake}
					>{unstaking ? 'Unstaking' : 'Unstake'}</button>
				{:else}
					<p class="font-bold">You have not staked anything yet.</p>
				{/if}
			</div>
		</div>
		<div class="flex flex-col items-center lg:text-left border-2 py-10 px-5 m-2">
			<h2 class="text-3xl font-bold text-center">Total Earned</h2>
			<p class="py-6">
				This is how much ETH you have earned and that you can claim.
			</p>
			<div class="flex flex-col justify-stretch">
				{#if totalEarned.gt(0)}
					<h3 class="font-bold text-2xl text-center">{formatEther(totalEarned)} ETH</h3>
					<h4 class="text-center">${parseFloat(utils.formatEther(totalEarnedInUSD)).toFixed(2)} USD</h4>
					<button 
						class="btn btn-primary btn-wide mt-5" 
						class:disabled={totalEarned.eq(0)}
						class:loading={claming}
						disabled={totalEarned.eq(0) || claming}
						on:click={claim}
					>{claming ? 'Claming' : 'Claim'}</button>
				{:else}
					<p class="font-bold">You have not earned anything yet.</p>
				{/if}
			</div>
		</div>
	</div>
</div>
