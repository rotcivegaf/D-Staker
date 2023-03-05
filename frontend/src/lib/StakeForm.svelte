<script type="ts">
  import {getStakingPoolContract} from "$utils/contracts";
	import {signer, address, onExpectedNetwork, provider} from "$store/wallet";
	import {showNotification, NotificationType} from '$store/notifications';
	import {BigNumber, Contract, utils} from 'ethers';

	import ConnectButton from "./ConnectButton.svelte";
	import SwitchNetworkButton from "./SwitchNetworkButton.svelte";
	import {simulate} from '$utils/simulator';

	const {formatEther} = utils;

	let loaded = false;
	let invalid = false;

	let stakingContract: Contract | undefined;
	let symbol: string = '';
	let balance = BigNumber.from(0);
	let assetsBalance = BigNumber.from(0);

	let inputAmount = 0;

	function setMaxEther() {
		inputAmount = Number(formatEther(balance));
	}

  async function load() {
		if (!$provider || !$address) {
			return;
		}

		stakingContract = await getStakingPoolContract();

		if (!stakingContract) {
			throw new Error("invalid contract");
		}

		[balance, symbol, assetsBalance] = await Promise.all([
			$provider.getBalance($address),
			stakingContract.symbol(),
			stakingContract.balanceOf($address),
		]);
		
		loaded = true;
	}

	let staking = false;
	async function stake() {
		if (!stakingContract) {
			showNotification("Invalid Staking Pool Contract", {
				type: NotificationType.Error
			});
			return;
		}
		staking = true;
		showNotification("Sending transaction", {
			type: NotificationType.InProgress
		});
		try {
			const rawTransaction = await stakingContract.populateTransaction.stake();
			const successfull = await simulate({
				...rawTransaction,
				value: utils.parseEther(inputAmount.toString()),
			});
			if (!successfull) {
				showNotification("The transaction will be reverted. Please, check the values", {
					type: NotificationType.Error
				});
				return;
			}
			const tx = await stakingContract.stake({
				value: utils.parseEther(inputAmount.toString()),
			});
			const { transactionHash } = await tx.wait();
			
			showNotification(`Success: Tx: <a href="https://goerli.etherscan.io/tx/${transactionHash}">${transactionHash}</a>`, {
				type: NotificationType.Check
			});
		} catch(error) {
			console.error(error);
			showNotification(error.message, {
				type: NotificationType.Error
			});
		}
		staking = false;
	}

	$: if ($signer) {
		load();
	}

	$: if ($address) {
		load();
	}

</script>

<section class="container mx-auto">
	<div
		class="mx-auto my-10 p-6 max-w-lg rounded-lg border border-gray-200 shadow-md "
	>
		<h5 class="mb-2 text-2xl font-bold tracking-tight ">
			Stake
		</h5>

		<p class="mb-3 font-normal">
			Stake your ETH to win rewards and to participate in Ethereum PoS
		</p>

		<hr />

		<div class="flex justify-center flex-col mx-auto w-full text-center max-w-lg mt-5">
			<div class="rounded-3xl bg-white shadow-sm w-full  mx-auto flex flex-col px-5 py-4 z-10">
				<h1 class="uppercase text-black text-3xl my-2 font-mono">Stake</h1>
				<div class="border rounded-lg p-2 flex flex-col">
					<div class="flex flex-row text-xs text-gray-700 justify-between items-center m-1">
						{#if loaded}
							<div>ETH to stake</div>
							<div>Balance: {Number(formatEther(balance)).toFixed(6)}</div>
						{:else}
							<div class="animate-pulse w-16 bg-slate-200 h-4" />
							<div class="animate-pulse w-20 bg-slate-200 h-4" />
						{/if}
					</div>
					<div class="flex flex-row  justify-between pt-1 items-center">
						{#if loaded}
						<input
							type="number"
							placeholder="0"
							min="0"
							max={formatEther(balance || '0')}
							disabled={!loaded}
							bind:value={inputAmount}
							step="0.01"
							class="input text-4xl outline-none w-72 font-mono"
						/>
						{:else}
              <div class="h-10 w-full bg-slate-200 animate-pulse"></div>
            {/if}
						<button
							class="btn btn-sm text-xs hover:border-gray-600 border-transparent border rounded px-1 mx-4 py-0 h-6"
							on:click|preventDefault={loaded ? setMaxEther : undefined}>MAX</button
						>
						<div class="text-xl font-semibold w-14">ETH</div>
					</div>
				</div>
				<div class="text-left" />

				<span class="text-black text-3xl text-center fill-black mx-auto py-2">
					<svg xmlns="http://www.w3.org/2000/svg" class="h-6 w-6" viewBox="0 0 384 512"
						><path
							d="M374.6 310.6l-160 160C208.4 476.9 200.2 480 192 480s-16.38-3.125-22.62-9.375l-160-160c-12.5-12.5-12.5-32.75 0-45.25s32.75-12.5 45.25 0L160 370.8V64c0-17.69 14.33-31.1 31.1-31.1S224 46.31 224 64v306.8l105.4-105.4c12.5-12.5 32.75-12.5 45.25 0S387.1 298.1 374.6 310.6z"
						/></svg
					>
				</span>
				<div class="border rounded-lg p-2 flex flex-col">
					<div class="flex flex-row text-xs text-gray-700 justify-between m-1">
						<div>Output</div>
						{#if loaded}
							<div>Balance: {Number(formatEther(assetsBalance)).toFixed(6)}</div>
						{:else}
							<div class="animate-pulse w-20 bg-base-200 h-4" />
						{/if}
					</div>
					<div class="flex flex-row  justify-between pt-1">
						<input
							type="number"
							placeholder="0"
							min="0"
							bind:value={inputAmount}
							readonly
							class="input text-4xl w-72 outline-none font-mono"
						/>
						<div class="flex flex-row">
							<div class="text-xl font-semibold w-14">{symbol}</div>
						</div>
					</div>
				</div>
				<div class="py-5">
					{#if !$onExpectedNetwork}
						<SwitchNetworkButton class="btn-big w-full" />
					{:else if !$address} 
						<ConnectButton class="btn-big w-full" />
					{:else}
						<button
							type="button"
							class="btn btn-primary btn-lg w-full rounded-xl py-4 font-semibold mt-4"
							class:loading={staking}
							on:click={stake}
							disabled={invalid || staking || (!inputAmount || inputAmount === 0)}
							class:cursor-wait={staking}
						>
							{staking ? 'staking' : 'stake'}
						</button>
					{/if}
				</div>
			</div>
			<div class="-mt-8 pt-10 shadow-lg max-w-lg w-[96%] rounded mx-auto">
				<div class="flex flex-col px-5 font-mono text-sm py-1">
					<div class="flex justify-between pb-0.5">
						<div class="">Target Stake</div>
						<div class="">32 ETH</div>
					</div>
					<div class="flex justify-between pb-0.5">
						<div class="">Expected APR</div>
						<div class="">4.76%</div>
					</div>
					<div class="flex justify-between pb-0.5">
						<div class="">Stake Duration</div>
						<div class="">6 Months</div>
					</div>
					<div class="flex justify-between pb-0.5">
						<div class="">Current stake</div>
						{#if loaded}
							<div class="">
								{Number(formatEther(assetsBalance)).toFixed(2)}<span class="pl-[3px]">ETH</span>
							</div>
						{:else}
							<div class="animate-pulse w-14 bg-slate-200 h-4" />
						{/if}
					</div>
				</div>
			</div>
		</div>
	</div>
</section>
