/**
 * API client for local GGUF models via llama-cpp-python.
 */
import { WEBUI_BASE_URL } from '$lib/constants';

export interface LocalModel {
	id: string;
	filename: string;
	file_size: number;
	file_size_human: string;
	is_loaded: boolean;
	loaded_at: number | null;
	n_gpu_layers: number | null;
	n_ctx: number | null;
	mmproj_filename: string | null;
}

export const getLocalModels = async (token: string = ''): Promise<LocalModel[]> => {
	const res = await fetch(`${WEBUI_BASE_URL}/llamacpp/models`, {
		method: 'GET',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			...(token && { authorization: `Bearer ${token}` })
		}
	});

	if (!res.ok) {
		const err = await res.json().catch(() => ({ detail: 'Falha ao buscar modelos locais' }));
		throw new Error(err.detail || 'Falha ao buscar modelos locais');
	}

	const data = await res.json();
	return data.models ?? [];
};

export const getLoadedLocalModels = async (token: string = ''): Promise<LocalModel[]> => {
	const res = await fetch(`${WEBUI_BASE_URL}/llamacpp/models/loaded`, {
		method: 'GET',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			...(token && { authorization: `Bearer ${token}` })
		}
	});

	if (!res.ok) {
		const err = await res.json().catch(() => ({ detail: 'Falha ao buscar modelos carregados' }));
		throw new Error(err.detail || 'Falha ao buscar modelos carregados');
	}

	const data = await res.json();
	return data.models ?? [];
};

export const getMmProjFiles = async (token: string = ''): Promise<string[]> => {
	const res = await fetch(`${WEBUI_BASE_URL}/llamacpp/models/mmproj`, {
		method: 'GET',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			...(token && { authorization: `Bearer ${token}` })
		}
	});

	if (!res.ok) {
		const err = await res.json().catch(() => ({ detail: 'Falha ao buscar arquivos mmproj' }));
		throw new Error(err.detail || 'Falha ao buscar arquivos mmproj');
	}

	const data = await res.json();
	return data.mmproj_files ?? [];
};

export const loadLocalModel = async (
	token: string = '',
	filename: string,
	n_gpu_layers: number = -1,
	n_ctx: number = 4096,
	mmproj_filename?: string | null,
	cache_type: string = 'q8_0'
): Promise<any> => {
	const res = await fetch(`${WEBUI_BASE_URL}/llamacpp/models/load`, {
		method: 'POST',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			...(token && { authorization: `Bearer ${token}` })
		},
		body: JSON.stringify({ filename, n_gpu_layers, n_ctx, mmproj_filename: mmproj_filename ?? null, cache_type })
	});

	if (!res.ok) {
		const err = await res.json().catch(() => ({ detail: 'Failed to load model' }));
		throw new Error(err.detail || 'Failed to load model');
	}

	return res.json();
};

export const unloadLocalModel = async (token: string = '', model_id: string): Promise<any> => {
	const res = await fetch(`${WEBUI_BASE_URL}/llamacpp/models/unload`, {
		method: 'POST',
		headers: {
			Accept: 'application/json',
			'Content-Type': 'application/json',
			...(token && { authorization: `Bearer ${token}` })
		},
		body: JSON.stringify({ model_id })
	});

	if (!res.ok) {
		const err = await res.json().catch(() => ({ detail: 'Failed to unload model' }));
		throw new Error(err.detail || 'Failed to unload model');
	}

	return res.json();
};
