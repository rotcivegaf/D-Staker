<script type="ts">
	import { metamask, expectedNetwork, switchNetwork, onExpectedNetwork } from '$store/wallet';
	import { showNotification, NotificationType } from '$store/notifications';

	import Spinner from '$lib/Spinner.svelte';

	let loading = false;
	async function onSwitchNetwork() {
		loading = true;
		showNotification('Switching network', {
			type: NotificationType.Error, 
		});
		try {
			await switchNetwork();
		} catch (error: any) {
			showNotification(error.message, {
				type: NotificationType.Error, 
			});
		}
		loading = false;
	}

	$: legend = loading
		? 'Switching'
		: !$onExpectedNetwork
		? `Switch to ${$expectedNetwork.name}`
		: $expectedNetwork.name;
</script>

{#if $metamask}
	<button
		on:click={onSwitchNetwork}
		disabled={loading}
		class="
			btn
			btn-primary
			${$$restProps.class || ''}
		"
		class:cursor-pointer={!$onExpectedNetwork}
	>
		{#if loading}
			<div class="pr-2">
				<Spinner />
			</div>
		{/if}

		<span>{legend}</span></button
	>
{/if}
