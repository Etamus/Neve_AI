<script>
	import { getContext } from 'svelte';
	const i18n = getContext('i18n');
	import WebSearchResults from '../WebSearchResults.svelte';
	import GlobeAlt from '$lib/components/icons/GlobeAlt.svelte';
	import Search from '$lib/components/icons/Search.svelte';
	import { t } from 'i18next';

	export let status = null;
	export let done = false;
</script>

{#if !status?.hidden}
	<div class="status-description flex items-center gap-2 py-0.5 w-full text-left">
		{#if status?.action === 'web_search' && (status?.urls || status?.items)}
			<WebSearchResults {status} done={done || status?.done}>
				<span class="text-sm">
					{#if status?.description?.includes('{{count}}')}
						{$i18n.t(status?.description, {
							count: (status?.urls || status?.items).length
						})}
					{:else if status?.description === 'No search query generated'}
						{$i18n.t('No search query generated')}
					{:else if status?.description === 'Generating search query'}
						{$i18n.t('Generating search query')}
					{:else}
						{status?.description}
					{/if}
				</span>
			</WebSearchResults>
		{:else if status?.action === 'knowledge_search'}
			<div class="flex flex-col justify-center -space-y-0.5">
				<div
					class="flex items-center gap-2 py-0.5 text-sm {(done || status?.done) === false
						? 'shimmer'
						: ''} text-gray-500 dark:text-gray-400 line-clamp-1 text-wrap"
				>
					<Search className="size-4 shrink-0" />
					{$i18n.t(`Searching Knowledge for "{{searchQuery}}"`, {
						searchQuery: status.query
					})}
				</div>
			</div>
		{:else if status?.action === 'web_search_queries_generated' && status?.queries}
			<div class="flex flex-col justify-center -space-y-0.5">
				<div
					class="flex items-center gap-2 py-0.5 text-sm text-gray-500 dark:text-gray-400"
				>
					<GlobeAlt className="size-4 shrink-0" strokeWidth="1.5" />
					<span class="{(done || status?.done) === false ? 'shimmer' : ''}">{$i18n.t(`Searching`)}</span>
				</div>

				<div class="flex gap-1.5 flex-wrap mt-2 pl-6">
					{#each status.queries as query, idx (query)}
						<div
							class="inline-flex items-center gap-1.5 rounded-md border border-gray-200 dark:border-gray-700/60 bg-white dark:bg-gray-900 px-2 py-1 text-xs text-gray-600 dark:text-gray-300"
						>
							<Search className="size-3" />
							<span class="line-clamp-1">{query}</span>
						</div>
					{/each}
				</div>
			</div>
		{:else if status?.action === 'queries_generated' && status?.queries}
			<div class="flex flex-col justify-center -space-y-0.5">
				<div
					class="flex items-center gap-2 py-0.5 text-sm text-gray-500 dark:text-gray-400"
				>
					<GlobeAlt className="size-4 shrink-0" strokeWidth="1.5" />
					<span class="{(done || status?.done) === false ? 'shimmer' : ''}">{$i18n.t(`Querying`)}</span>
				</div>

				<div class="flex gap-1.5 flex-wrap mt-2 pl-6">
					{#each status.queries as query, idx (query)}
						<div
							class="inline-flex items-center gap-1.5 rounded-md border border-gray-200 dark:border-gray-700/60 bg-white dark:bg-gray-900 px-2 py-1 text-xs text-gray-600 dark:text-gray-300"
						>
							<Search className="size-3" />
							<span class="line-clamp-1">{query}</span>
						</div>
					{/each}
				</div>
			</div>
		{:else if status?.action === 'sources_retrieved' && status?.count !== undefined}
			<div class="flex flex-col justify-center -space-y-0.5">
				<div
					class="flex items-center gap-2 py-0.5 text-sm {(done || status?.done) === false
						? 'shimmer'
						: ''} text-gray-500 dark:text-gray-400 line-clamp-1 text-wrap"
				>
					<GlobeAlt className="size-4 shrink-0" strokeWidth="1.5" />
					{#if status.count === 0}
						{$i18n.t('No sources found')}
					{:else if status.count === 1}
						{$i18n.t('Retrieved 1 source')}
					{:else}
						<!-- {$i18n.t('Source')} -->
						<!-- {$i18n.t('No source available')} -->
						<!-- {$i18n.t('No distance available')} -->
						<!-- {$i18n.t('Retrieved {{count}} sources')} -->
						{$i18n.t('Retrieved {{count}} sources', {
							count: status.count
						})}
					{/if}
					</div>
			</div>
		{:else}
			<div class="flex flex-col justify-center -space-y-0.5">
				<div
					class="flex items-center gap-2 py-0.5 text-sm {(done || status?.done) === false
						? 'shimmer'
						: ''} text-gray-500 dark:text-gray-400 line-clamp-1 text-wrap"
				>
					<GlobeAlt className="size-4 shrink-0" strokeWidth="1.5" />
					<!-- $i18n.t(`Searching "{{searchQuery}}"`) -->
					{#if status?.description?.includes('{{searchQuery}}')}
						{$i18n.t(status?.description, {
							searchQuery: status?.query
						})}
					{:else if status?.description === 'No search query generated'}
						{$i18n.t('No search query generated')}
					{:else if status?.description === 'Generating search query'}
						{$i18n.t('Generating search query')}
					{:else if status?.description === 'Searching the web'}
						{$i18n.t('Searching the web')}
					{:else}
						{status?.description}
					{/if}
					</div>
			</div>
		{/if}
	</div>
{/if}
