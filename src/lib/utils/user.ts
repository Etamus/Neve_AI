const DEFAULT_USER_NAMES = new Set(['user', 'usuario']);

const normalizeUserName = (name?: string | null) =>
	(name ?? '')
		.trim()
		.normalize('NFD')
		.replace(/[\u0300-\u036f]/g, '')
		.toLowerCase();

export const getCustomUserName = (name?: string | null) => {
	const trimmedName = (name ?? '').trim();
	return DEFAULT_USER_NAMES.has(normalizeUserName(trimmedName)) ? '' : trimmedName;
};

export const getUserFirstName = (name?: string | null) =>
	getCustomUserName(name).split(/\s+/)[0] ?? '';

export const getUserDisplayName = (name?: string | null) => getCustomUserName(name) || 'Usuário';
