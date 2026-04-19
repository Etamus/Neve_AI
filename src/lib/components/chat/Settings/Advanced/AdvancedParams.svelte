<script lang="ts">
	import Tooltip from '$lib/components/common/Tooltip.svelte';
	import { getContext } from 'svelte';

	const i18n = getContext('i18n');

	export let onChange: (params: any) => void = () => {};

	export let admin = false;
	export let custom = false;
	export let separators = false;

	const defaultParams = {
		// Advanced - llama.cpp compatible params only
		stream_response: null, // Set stream responses for this model individually
		seed: -1,
		stop: null,
		temperature: null,
		max_tokens: null,
		top_k: 0,
		top_p: 1,
		min_p: null,
		frequency_penalty: 0,
		presence_penalty: 0,
		mirostat: null,
		mirostat_eta: null,
		mirostat_tau: null,
		repeat_penalty: 1,
		xtc_threshold: null,
		xtc_probability: null,
		dry_multiplier: null,
		dry_allowed_length: null,
		dry_base: null,
		cache_type: null
	};

	export let params = defaultParams;
	$: if (params) {
		onChange(params);
	}
</script>
<div class=" space-y-1 text-xs pb-safe-bottom">
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'The temperature of the model. Increasing the temperature will make the model answer more creatively.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('Temperature')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded-sm transition shrink-0 outline-hidden"
					type="button"
					on:click={() => {
						params.temperature = (params?.temperature ?? null) === null ? 0.8 : null;
					}}
				>
					{#if (params?.temperature ?? null) === null}
						<span class="ml-2 self-center"> {$i18n.t('Default')} </span>
					{:else}
						<span class="ml-2 self-center"> {$i18n.t('Custom')} </span>
					{/if}
				</button>
			</div>
		</Tooltip>

		{#if (params?.temperature ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						id="steps-range"
						type="range"
						min="0"
						max="2"
						step="0.05"
						bind:value={params.temperature}
						class="w-full h-2 rounded-lg appearance-none cursor-pointer bg-gray-200 dark:bg-gray-700"
					/>
				</div>
				<div>
					<input
						bind:value={params.temperature}
						type="number"
						class=" bg-transparent text-center w-14"
						min="0"
						max="2"
						step="any"
					/>
				</div>
			</div>
		{/if}
	</div>
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'This option sets the maximum number of tokens the model can generate in its response. Increasing this limit allows the model to provide longer answers, but it may also increase the likelihood of unhelpful or irrelevant content being generated.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('Máximo de tokens')}
				</div>

				<button
					class="p-1 px-3 text-xs flex rounded-sm transition shrink-0 outline-hidden"
					type="button"
					on:click={() => {
						params.max_tokens = (params?.max_tokens ?? null) === null ? 128 : null;
					}}
				>
					{#if (params?.max_tokens ?? null) === null}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{:else}
						<span class="ml-2 self-center">{$i18n.t('Custom')}</span>
					{/if}
				</button>
			</div>
		</Tooltip>

		{#if (params?.max_tokens ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						id="steps-range"
						type="range"
						min="-2"
						max="131072"
						step="1"
						bind:value={params.max_tokens}
						class="w-full h-2 rounded-lg appearance-none cursor-pointer bg-gray-200 dark:bg-gray-700"
					/>
				</div>
				<div>
					<input
						bind:value={params.max_tokens}
						type="number"
						class=" bg-transparent text-center w-14"
						min="-2"
						step="1"
					/>
				</div>
			</div>
		{/if}
	</div>
		<div>
		<Tooltip
			content={$i18n.t(
				'When enabled, the model will respond to each chat message in real-time, generating a response as soon as the user sends a message. This mode is useful for live chat applications, but may impact performance on slower hardware.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class=" py-0.5 flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('Stream de resposta')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded-sm transition"
					on:click={() => {
						params.stream_response =
							(params?.stream_response ?? null) === null
								? true
								: params.stream_response
									? false
									: null;
					}}
					type="button"
				>
					{#if params.stream_response === true}
						<span class="ml-2 self-center">{$i18n.t('On')}</span>
					{:else if params.stream_response === false}
						<span class="ml-2 self-center">{$i18n.t('Off')}</span>
					{:else}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{/if}
				</button>
			</div>
		</Tooltip>
	</div>
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'Sets the stop sequences to use. When this pattern is encountered, the LLM will stop generating text and return. Multiple stop patterns may be set by specifying multiple separate stop parameters in a modelfile.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('Sequência de parada')}
				</div>

				<button
					class="p-1 px-3 text-xs flex rounded-sm transition shrink-0 outline-hidden"
					type="button"
					on:click={() => {
						params.stop = (params?.stop ?? null) === null ? '' : null;
					}}
				>
					{#if (params?.stop ?? null) === null}
						<span class="ml-2 self-center"> {$i18n.t('Default')} </span>
					{:else}
						<span class="ml-2 self-center"> {$i18n.t('Custom')} </span>
					{/if}
				</button>
			</div>
		</Tooltip>

		{#if (params?.stop ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						class="text-sm w-full bg-transparent outline-hidden outline-none"
						type="text"
						placeholder={$i18n.t('Enter stop sequence')}
						bind:value={params.stop}
						autocomplete="off"
					/>
				</div>
			</div>
		{/if}
	</div>
	<hr class=" border-gray-200 dark:border-gray-700 my-2 w-full" />
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'Tipo de quantização do KV cache. Q8_0 reduz ~50% da VRAM com qualidade praticamente igual. Q4_0 reduz ~75%. FP16 não quantiza. Requer recarregar o modelo para aplicar.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('cache_type')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded-sm transition shrink-0 outline-hidden"
					type="button"
					on:click={() => {
						const order = [null, 'q8_0', 'q4_0', 'f16'];
						const idx = order.indexOf(params?.cache_type ?? null);
						const next = order[(idx + 1) % order.length];
						params.cache_type = next;
						if (next) {
							localStorage.setItem('llamacpp_cache_type', next);
						} else {
							localStorage.removeItem('llamacpp_cache_type');
						}
					}}
				>
					{#if (params?.cache_type ?? null) === null}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{:else if params.cache_type === 'q8_0'}
						<span class="ml-2 self-center">Q8_0</span>
					{:else if params.cache_type === 'q4_0'}
						<span class="ml-2 self-center">Q4_0</span>
					{:else if params.cache_type === 'f16'}
						<span class="ml-2 self-center">FP16</span>
					{/if}
				</button>
			</div>
		</Tooltip>
	</div>
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'Alternative to the top_p, and aims to ensure a balance of quality and variety. The parameter p represents the minimum probability for a token to be considered, relative to the probability of the most likely token. For example, with p=0.05 and the most likely token having a probability of 0.9, logits with a value less than 0.045 are filtered out.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('min_p')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded-sm transition shrink-0 outline-hidden"
					type="button"
					on:click={() => {
						params.min_p = (params?.min_p ?? null) === null ? 0.0 : null;
					}}
				>
					{#if (params?.min_p ?? null) === null}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{:else}
						<span class="ml-2 self-center">{$i18n.t('Custom')}</span>
					{/if}
				</button>
			</div>
		</Tooltip>

		{#if (params?.min_p ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						id="steps-range"
						type="range"
						min="0"
						max="1"
						step="0.05"
						bind:value={params.min_p}
						class="w-full h-2 rounded-lg appearance-none cursor-pointer bg-gray-200 dark:bg-gray-700"
					/>
				</div>
				<div>
					<input
						bind:value={params.min_p}
						type="number"
						class=" bg-transparent text-center w-14"
						min="0"
						max="1"
						step="any"
					/>
				</div>
			</div>
		{/if}
	</div>
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'Limiar de amostragem XTC (eXclude Top Choices). Tokens com probabilidade acima deste valor são candidatos à exclusão. Intervalo 0–1. Padrão 0.1.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('xtc_threshold')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded transition flex-shrink-0 outline-none"
					type="button"
					on:click={() => {
						params.xtc_threshold = (params?.xtc_threshold ?? null) === null ? 0.1 : null;
					}}
				>
					{#if (params?.xtc_threshold ?? null) === null}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{:else}
						<span class="ml-2 self-center">{$i18n.t('Custom')}</span>
					{/if}
				</button>
			</div>
		</Tooltip>
		{#if (params?.xtc_threshold ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						id="steps-range"
						type="range"
						min="0"
						max="1"
						step="0.01"
						bind:value={params.xtc_threshold}
						class="w-full h-2 rounded-lg appearance-none cursor-pointer bg-gray-200 dark:bg-gray-700"
					/>
				</div>
				<div>
					<input
						bind:value={params.xtc_threshold}
						type="number"
						class=" bg-transparent text-center w-14"
						min="0"
						max="1"
						step="any"
					/>
				</div>
			</div>
		{/if}
	</div>
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'Probabilidade de amostragem XTC. Controla a chance de os tokens candidatos serem excluídos. Intervalo 0–1. Padrão 0.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('xtc_probability')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded transition flex-shrink-0 outline-none"
					type="button"
					on:click={() => {
						params.xtc_probability = (params?.xtc_probability ?? null) === null ? 0 : null;
					}}
				>
					{#if (params?.xtc_probability ?? null) === null}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{:else}
						<span class="ml-2 self-center">{$i18n.t('Custom')}</span>
					{/if}
				</button>
			</div>
		</Tooltip>
		{#if (params?.xtc_probability ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						id="steps-range"
						type="range"
						min="0"
						max="1"
						step="0.01"
						bind:value={params.xtc_probability}
						class="w-full h-2 rounded-lg appearance-none cursor-pointer bg-gray-200 dark:bg-gray-700"
					/>
				</div>
				<div>
					<input
						bind:value={params.xtc_probability}
						type="number"
						class=" bg-transparent text-center w-14"
						min="0"
						max="1"
						step="any"
					/>
				</div>
			</div>
		{/if}
	</div>
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'Multiplicador de penalidade de repetição DRY (Não Se Repita). 0 desativa o DRY. Valores maiores penalizam sequências repetitivas com mais intensidade. Padrão 0.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('dry_multiplier')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded transition flex-shrink-0 outline-none"
					type="button"
					on:click={() => {
						params.dry_multiplier = (params?.dry_multiplier ?? null) === null ? 0 : null;
					}}
				>
					{#if (params?.dry_multiplier ?? null) === null}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{:else}
						<span class="ml-2 self-center">{$i18n.t('Custom')}</span>
					{/if}
				</button>
			</div>
		</Tooltip>
		{#if (params?.dry_multiplier ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						id="steps-range"
						type="range"
						min="0"
						max="3"
						step="0.05"
						bind:value={params.dry_multiplier}
						class="w-full h-2 rounded-lg appearance-none cursor-pointer bg-gray-200 dark:bg-gray-700"
					/>
				</div>
				<div>
					<input
						bind:value={params.dry_multiplier}
						type="number"
						class=" bg-transparent text-center w-14"
						min="0"
						max="3"
						step="any"
					/>
				</div>
			</div>
		{/if}
	</div>
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'Comprimento permitido pelo DRY. Sequências menores que este valor não são penalizadas pelo DRY. Padrão 2.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('dry_allowed_length')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded transition flex-shrink-0 outline-none"
					type="button"
					on:click={() => {
						params.dry_allowed_length = (params?.dry_allowed_length ?? null) === null ? 2 : null;
					}}
				>
					{#if (params?.dry_allowed_length ?? null) === null}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{:else}
						<span class="ml-2 self-center">{$i18n.t('Custom')}</span>
					{/if}
				</button>
			</div>
		</Tooltip>
		{#if (params?.dry_allowed_length ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						id="steps-range"
						type="range"
						min="1"
						max="10"
						step="1"
						bind:value={params.dry_allowed_length}
						class="w-full h-2 rounded-lg appearance-none cursor-pointer bg-gray-200 dark:bg-gray-700"
					/>
				</div>
				<div>
					<input
						bind:value={params.dry_allowed_length}
						type="number"
						class=" bg-transparent text-center w-14"
						min="1"
						max="10"
						step="1"
					/>
				</div>
			</div>
		{/if}
	</div>
		<div class=" py-0.5 w-full justify-between">
		<Tooltip
			content={$i18n.t(
				'Base exponencial do DRY. A penalidade cresce exponencialmente com o comprimento da sequência. Valores maiores penalizam mais repetições longas. Padrão 1.75.'
			)}
			placement="top-start"
			className="inline-tooltip"
		>
			<div class="flex w-full justify-between">
				<div class=" self-center text-xs">
					{$i18n.t('dry_base')}
				</div>
				<button
					class="p-1 px-3 text-xs flex rounded transition flex-shrink-0 outline-none"
					type="button"
					on:click={() => {
						params.dry_base = (params?.dry_base ?? null) === null ? 1.75 : null;
					}}
				>
					{#if (params?.dry_base ?? null) === null}
						<span class="ml-2 self-center">{$i18n.t('Default')}</span>
					{:else}
						<span class="ml-2 self-center">{$i18n.t('Custom')}</span>
					{/if}
				</button>
			</div>
		</Tooltip>
		{#if (params?.dry_base ?? null) !== null}
			<div class="flex mt-0.5 space-x-2">
				<div class=" flex-1">
					<input
						id="steps-range"
						type="range"
						min="1"
						max="2.5"
						step="0.05"
						bind:value={params.dry_base}
						class="w-full h-2 rounded-lg appearance-none cursor-pointer bg-gray-200 dark:bg-gray-700"
					/>
				</div>
				<div>
					<input
						bind:value={params.dry_base}
						type="number"
						class=" bg-transparent text-center w-14"
						min="1"
						max="2.5"
						step="any"
					/>
				</div>
			</div>
		{/if}
	</div>

	{#if admin}
		{#if custom && admin}
			<div class="flex flex-col justify-center">
				{#each Object.keys(params?.custom_params ?? {}) as key}
					<div class=" py-0.5 w-full justify-between mb-1">
						<div class="flex w-full justify-between">
							<div class=" self-center text-xs">
								<input
									type="text"
									class=" text-xs w-full bg-transparent outline-none"
									placeholder={$i18n.t('Custom Parameter Name')}
									value={key}
									on:change={(e) => {
										const newKey = e.target.value.trim();
										if (newKey && newKey !== key) {
											params.custom_params[newKey] = params.custom_params[key];
											delete params.custom_params[key];
											params = {
												...params,
												custom_params: { ...params.custom_params }
											};
										}
									}}
								/>
							</div>
							<button
								class="p-1 px-3 text-xs flex rounded-sm transition shrink-0 outline-hidden"
								type="button"
								on:click={() => {
									delete params.custom_params[key];
									params = {
										...params,
										custom_params: { ...params.custom_params }
									};
								}}
							>
								{$i18n.t('Remove')}
							</button>
						</div>
						<div class="flex mt-0.5 space-x-2">
							<div class=" flex-1">
								<input
									bind:value={params.custom_params[key]}
									type="text"
									class="text-sm w-full bg-transparent outline-hidden outline-none"
									placeholder={$i18n.t('Custom Parameter Value')}
								/>
							</div>
						</div>
					</div>
				{/each}
			</div>
		{/if}
	{/if}
</div>