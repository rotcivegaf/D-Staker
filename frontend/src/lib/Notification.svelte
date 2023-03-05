<script lang="ts">
	import { tweened } from 'svelte/motion';
	import { cubicOut } from 'svelte/easing';
	import { onDestroy } from 'svelte';

	import { fade, fly } from 'svelte/transition';

	import { message, show, config, hideNotification, NotificationType } from '$store/notifications';

	import Spinner from './Spinner.svelte';

	import TiCancel from  'svelte-icons/ti/TiCancel.svelte';
	import TiInfo from 'svelte-icons/ti/TiInfo.svelte';
	import TiTick from 'svelte-icons/ti/TiTick.svelte';

	const progress = tweened(0, {
		duration: 400,
		easing: cubicOut
	});

	let progressInterval: ReturnType<typeof setInterval>;

	const unsubscribe = show.subscribe((show) => {
		if (!show) {
			clearInterval(progressInterval);
			return;
		}

		if ($config.duration) {
			progress.set(0);

			const step = $config.duration / 10;

			progressInterval = setInterval(() => {
				if ($progress >= 1) {
					hideNotification();
					return;
				}
				progress.set($progress + 0.1);
			}, step);
		}
	});

	onDestroy(unsubscribe);

	const icons: Record<number, any> = {
		[NotificationType.Error]: TiCancel,
		[NotificationType.Warning]: TiInfo,
		[NotificationType.Check]: TiTick,
		[NotificationType.InProgress]: Spinner
	};

	const notificationTypesClasses: Record<number, string> = {
		[NotificationType.Error]: 'bg-red-500 text-white',
		[NotificationType.Warning]: 'bg-yellow-300 text-black',
		[NotificationType.Check]: 'bg-green-500 text-white',
		[NotificationType.InProgress]: 'bg-slate-200'
	};

	$: icon = $config.type !== undefined ? icons[$config.type] : TiTick;
	$: classes = $config.type !== undefined ? notificationTypesClasses[$config.type] : '';
</script>

{#if $show}
	<div
		in:fly={{ y: 200, duration: 200 }}
		out:fade
		class={`
      fixed 
      right-5
      bottom-5
      bg-white
      rounded-lg
      shadow
      flex
      flex-col
      w-auto
      left-5
      md:left-auto
      ${classes}
    `}
		role="alert"
	>
		<div
			class="
      flex
      items-center
      justify-between
      w-full
      py-4 px-4
    "
		>
			<div class="flex flex-row items-center mr-10">
				<div class="w-10 h-10">
					<svelte:component this={icon} />
				</div>
				<div class="ml-3 text-sm font-normal">{@html $message}</div>
			</div>

			{#if !$config.duration}
				<button
					type="button"
					on:click={hideNotification}
					class="ml-auto -mx-1.5 -my-1.5 "
					data-dismiss-target="#toast-default"
					aria-label="Close"
				>
					<span class="sr-only">Close</span>
					<svg
						aria-hidden="true"
						class="w-5 h-5"
						fill="currentColor"
						viewBox="0 0 20 20"
						xmlns="http://www.w3.org/2000/svg"
						><path
							fill-rule="evenodd"
							d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z"
							clip-rule="evenodd"
						/></svg
					>
				</button>
			{/if}
		</div>
		{#if $config.duration}
			<progress value={$progress} class="w-full h-1 rounded-lg border-slate-800" />
		{/if}
	</div>
{/if}
