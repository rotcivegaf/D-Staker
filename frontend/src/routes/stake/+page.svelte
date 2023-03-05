<script lang="ts">
	import StakeForm from '$lib/StakeForm.svelte';
</script>

<svelte:head>
	<title>Home</title>
	<meta name="description" content="Svelte demo app" />
</svelte:head>

<div class="hero min-h-screen bg-base-200">
	<div class="hero-content flex-col lg:flex-row-reverse">
		<div class="text-center lg:text-left">
			<h1 class="text-5xl font-bold">Stake ETH now to start earning rewards!</h1>
			<p class="py-6">
				You can stake any ETH amount you want and you will start participate in the ethereum
				consensus layer.
			</p>
			<p>
				Rewards will be distributed fairly between all the stakers. The more ETH you stake, the more
				rewards you will eran!
			</p>
		</div>
		<StakeForm />
	</div>
</div>
