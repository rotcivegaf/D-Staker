<script lang="ts">
	import {getStakingPoolContract, getWETHContract} from "$utils/contracts";
	import {signer, address, provider} from "$store/wallet";
	import {showNotification, NotificationType} from "$store/notifications";
	import {BigNumber, utils, Contract} from 'ethers';
	import {simulate} from '$utils/simulator';
	
	const {formatEther} = utils;

	let loading = false;
	let stakingContract: Contract | undefined; 
	let wethContract: Contract | undefined;

	let symbol: string = '';
	let totalEarned = BigNumber.from(0);
	let totalEarnedInUSD = BigNumber.from(0);
	let totalStaked = BigNumber.from(0);
	let totalStakedInUSD = BigNumber.from(0);
	let wethAvailable = BigNumber.from(0);
	let availableForUnstake = BigNumber.from(0);

	$: availableForUnstake = totalStaked.lt(wethAvailable) ? totalStaked : wethAvailable;

	async function loadInitialValues() {
		if (!stakingContract) {
			showNotification("Invalid Staking Pool Contract", {
				type: NotificationType.Error
			});
			return;
		}

		if (!wethContract) {
			showNotification("Invalid Weth Contract", {
				type: NotificationType.Error
			});
			return;
		}

		[totalEarned, totalEarnedInUSD, totalStaked, totalStakedInUSD, symbol, wethAvailable] = await Promise.all([ 
			stakingContract.calcRewards($address), 
			stakingContract.calcRewardsInUSD($address),
			stakingContract.stakeOf($address), 
			stakingContract.stakeOfInUSD($address), 
			stakingContract.symbol(),
			wethContract.balanceOf(stakingContract.address), 
		]);
	}

	async function load() {
		loading = true;

		if (!$provider || !$address) {
			return;
		}

		[stakingContract, wethContract] = await Promise.all([
			getStakingPoolContract(),
			getWETHContract(),
		])

		await loadInitialValues();
	}

	let claming = false;
	async function claim() {
		if (!stakingContract) {
			showNotification("Invalid Staking Pool Contract", {
				type: NotificationType.Error
			});
			return;
		}

		if (!wethContract) {
			showNotification("Invalid Weth Contract", {
				type: NotificationType.Error
			});
			return;
		}

		claming = true;
		try {
			const wethAvailable = await wethContract.balanceOf(stakingContract.address);

			const rawTransaction = await stakingContract.populateTransaction.claim();
			const successfull = await simulate(rawTransaction);
			if (!successfull) {
				showNotification("The transaction will be reverted. Please, check the values", {
					type: NotificationType.Error
				});
				return;
			}

			const tx = await stakingContract.claim();

			const { transactionHash } = await tx.wait();
			
			showNotification(`Success: Tx: <a href="https://goerli.etherscan.io/tx/${transactionHash}">${transactionHash}</a>`, {
				type: NotificationType.Check
			});

			await loadInitialValues();
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
			const rawTransaction = await stakingContract.populateTransaction.unstake(availableForUnstake);
			const successfull = await simulate(rawTransaction);
			if (!successfull) {
				showNotification("The transaction will be reverted. Please, check the values", {
					type: NotificationType.Error
				});
				return;
			}

			const tx = await stakingContract.unstake(availableForUnstake);
			
			const { transactionHash } = await tx.wait();
			
			showNotification(`Success: Tx: <a href="https://goerli.etherscan.io/tx/${transactionHash}">${transactionHash}</a>`, {
				type: NotificationType.Check
			});

			await loadInitialValues();
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
					<h4 
						class="text-center font-bold"
						class:text-green-700={availableForUnstake.gt(0)}
						class:text-red-700={availableForUnstake.eq(0)}
					>Available: {formatEther(availableForUnstake)} ETH</h4>
					<h4 class="text-center">${parseFloat(utils.formatEther(totalStakedInUSD)).toFixed(2)} USD</h4>
					<button 
						class="btn btn-primary btn-wide mt-5"
						class:disabled={availableForUnstake.eq(0)}
						class:loading={unstaking}
						disabled={availableForUnstake.eq(0) || unstaking}
						class:cursor-not-allowed={availableForUnstake.eq(0)}
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
