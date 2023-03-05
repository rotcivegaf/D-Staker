<script lang="ts">
	import { onMount } from 'svelte';
	import {initTheme} from '$store/theme';

	import '../app.postcss';

	import Header from '$lib/Header.svelte';
	import Footer from '$lib/Footer.svelte';
	import Notification from '$lib/Notification.svelte';

	import { init } from '$store/wallet';

	onMount(() => {
		init();
		initTheme();
	});
</script>

<Header />

<main class="content flex-1 flex-col text-sm flex justify-center font-mono">
	<slot />
</main>

<Footer />

<Notification />

