<script>
	import ConnectButton from '$lib/ConnectButton.svelte';
	import SwitchNetworkButton from '$lib/SwitchNetworkButton.svelte';
	import ThemeSwitcher from "$lib/ThemeSwitcher.svelte";

	import {onExpectedNetwork, address} from "$store/wallet";
</script>

<header class="header">
	<div class="navbar bg-base-100">
		<div class="navbar-start">
			{#if $onExpectedNetwork}
				<ConnectButton />
			{:else}
				<SwitchNetworkButton />
			{/if}
		</div>
		<div class="navbar-center">
			<ul class="menu menu-horizontal px-1">
      	<li><a class="px-1 md:px-10" href="/">Home</a></li>
				<li><a class="px-1 md:px-10" href="/dashboard">Dashboard</a></li>
				<!-- <li><a href="/claim">Claim</a></li> -->
				<li><a class="px-1 md:px-10" href="/stake">Stake</a></li>
			</ul>
		</div>
		<div class="navbar-end">
			<ThemeSwitcher />
		</div>
	</div>
</header>