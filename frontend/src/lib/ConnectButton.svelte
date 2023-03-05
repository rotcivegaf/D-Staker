<script type="ts">
	

	let sizeClass = "btn-${size}"

	import { address, connect, onExpectedNetwork } from '$store/wallet';
	import {showNotification, NotificationType } from '$store/notifications';

	import Spinner from '$lib/Spinner.svelte';

	let loading = false;
	async function onConnect() {
		loading = true;
		try {
			await connect();
		} catch(error: any) {
			showNotification(error.message, {
				type: NotificationType.Error
			});
		}
		loading = false;
	}

	$: legend = loading ? 'Connecting' : $address ? $address : 'Conect Wallet';
</script>

{#if $onExpectedNetwork}
	<button
		on:click={onConnect}
		disabled={loading || !$onExpectedNetwork}
		class={`
			btn
			btn-primary
			${$$restProps.class || ''}
		`}
		class:cursor-pointer={!$address}
	>
		{#if loading}
			<div class="pr-2">
				<Spinner />
			</div>
		{/if}

		<span
			class="overflow-ellipsis overflow-hidden w-24 md:w-32 lg:w-auto max-w-xs
	">{legend}</span
		>
	</button>
{/if}
