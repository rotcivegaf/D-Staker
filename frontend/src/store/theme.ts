import { writable, get } from 'svelte/store';

export enum Theme {
	DARK = 'dark',
	LIGHT = 'light'
}

export const theme = writable<Theme>(Theme.LIGHT);

export function initTheme() {
	if (
		localStorage.getItem('theme') === Theme.DARK ||
		(!('theme' in localStorage) &&
			window.matchMedia(`(prefers-color-scheme: ${Theme.DARK})`).matches)
	) {
		setTheme(Theme.DARK);
	} else {
		setTheme(Theme.LIGHT);
	}
}

export function setTheme(newTheme: Theme) {
	theme.set(newTheme);
	if (newTheme === Theme.DARK) {
		document.querySelector('html').setAttribute('data-theme', Theme.DARK);
	} else {
		document.querySelector('html').setAttribute('data-theme', Theme.LIGHT);
	}
	localStorage.setItem('theme', newTheme);
}

export async function toggleTheme() {
	let newTheme = Theme.DARK;
	if ((await get(theme)) === Theme.DARK) {
		newTheme = Theme.LIGHT;
	}
	setTheme(newTheme);
}
