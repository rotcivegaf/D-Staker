import { writable, type Writable } from 'svelte/store';

export enum NotificationType {
	Error,
	Warning,
	Check,
	InProgress
}

export const show: Writable<boolean> = writable(false);
export const message: Writable<string | undefined> = writable(undefined);
export const config: Writable<NotifcationConfig> = writable({});

type NotifcationConfig = {
	duration?: number;
	type?: NotificationType;
};

const defaultNotificationConfig = {
	type: NotificationType.InProgress
};

export function showNotification(_message: string, _config: NotifcationConfig = {}) {
	const wait = show ? 500 : 0;
	hideNotification();
	setTimeout(() => {
		config.update(() => ({ ...defaultNotificationConfig, ..._config }));
		message.update(() => _message);
		show.update(() => true);
	}, wait);
}

export function hideNotification() {
	show.update(() => false);
}

export function updateNotificationMessage(_message: string) {
	message.update(() => _message);
	show.update(() => true);
}
