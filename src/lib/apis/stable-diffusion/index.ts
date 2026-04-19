import { STABLE_DIFFUSION_API_BASE_URL } from '$lib/constants';

export const getSDConfig = async (token: string = '') => {
	const res = await fetch(`${STABLE_DIFFUSION_API_BASE_URL}/config`, {
		method: 'GET',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			...(token && { authorization: `Bearer ${token}` })
		}
	});

	if (!res.ok) {
		const err = await res.json();
		throw err.detail || 'Server connection failed';
	}

	return res.json();
};

export const updateSDConfig = async (token: string = '', config: object) => {
	const res = await fetch(`${STABLE_DIFFUSION_API_BASE_URL}/config/update`, {
		method: 'POST',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			...(token && { authorization: `Bearer ${token}` })
		},
		body: JSON.stringify(config)
	});

	if (!res.ok) {
		const err = await res.json();
		throw err.detail || 'Server connection failed';
	}

	return res.json();
};
