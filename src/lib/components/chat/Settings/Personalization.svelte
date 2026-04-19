<script lang="ts">
	import Switch from '$lib/components/common/Switch.svelte';
	import { config, models, settings, user } from '$lib/stores';
	import { createEventDispatcher, onMount, getContext, tick } from 'svelte';
	import { toast } from 'svelte-sonner';
	import ManageModal from './Personalization/ManageModal.svelte';
	import Tooltip from '$lib/components/common/Tooltip.svelte';
	const dispatch = createEventDispatcher();

	const i18n = getContext('i18n');

	export let saveSettings: Function;

	let showManageModal = false;

	// Addons
	let enableMemory = false;
	let chatBubble = true;
	let showUsername = false;

	onMount(async () => {
		enableMemory = $settings?.memory ?? false;
		chatBubble = $settings?.chatBubble ?? true;
		showUsername = $settings?.showUsername ?? false;
	});
</script>

<ManageModal bind:show={showManageModal} />

<form
	id="tab-personalization"
	class="flex flex-col h-full justify-between space-y-3 text-sm"
	on:submit|preventDefault={() => {
		dispatch('save');
	}}
>
	<div class="py-1 overflow-y-scroll max-h-[28rem] md:max-h-full">
		<div>
			<div class="flex items-center justify-between mb-1">
				<Tooltip
					content={$i18n.t(
						'This is an experimental feature, it may not function as expected and is subject to change at any time.'
					)}
				>
					<div class="flex items-center gap-2 text-sm font-medium">
						{$i18n.t('Memory')}
						<span
							class="text-[0.65rem] font-medium uppercase px-1.5 py-0.5 rounded-full bg-gray-100 dark:bg-gray-800 text-gray-500 dark:text-gray-400"
							>{$i18n.t('Experimental')}</span
						>
					</div>
				</Tooltip>

				<div class="">
					<Switch
						bind:state={enableMemory}
						on:change={async () => {
							saveSettings({ memory: enableMemory });
						}}
					/>
				</div>
			</div>
		</div>

		<div class="text-xs text-gray-600 dark:text-gray-400">
			<div>
				{$i18n.t(
					"You can personalize your interactions with LLMs by adding memories through the 'Manage' button below, making them more helpful and tailored to you."
				)}
			</div>

			<!-- <div class="mt-3">
				To understand what LLM remembers or teach it something new, just chat with it:

				<div>- “Remember that I like concise responses.”</div>
				<div>- “I just got a puppy!”</div>
				<div>- “What do you remember about me?”</div>
				<div>- “Where did we leave off on my last project?”</div>
			</div> -->
		</div>

		<div class="mt-3 mb-1 ml-1">
			<button
				type="button"
				class="text-xs px-3 py-1 font-medium hover:bg-black/5 dark:hover:bg-white/5 outline outline-1 outline-gray-300 dark:outline-gray-800 rounded-3xl"
				on:click={() => {
					showManageModal = true;
				}}
			>
				{$i18n.t('Manage')}
			</button>
		</div>

		<hr class="my-3 border-gray-100 dark:border-gray-800" />

		<div>
			<div class=" py-0.5 flex w-full justify-between">
				<div id="chat-bubble-ui-label" class=" self-center text-xs">
					{$i18n.t('Chat Bubble UI')}
				</div>

				<div class="flex items-center gap-2 p-1">
					<Switch
						tooltip={true}
						ariaLabelledbyId="chat-bubble-ui-label"
						bind:state={chatBubble}
						on:change={() => {
							saveSettings({ chatBubble });
						}}
					/>
				</div>
			</div>
		</div>

		{#if !chatBubble}
			<div>
				<div class=" py-0.5 flex w-full justify-between">
					<div id="chat-bubble-username-label" class=" self-center text-xs">
						{$i18n.t('Display the username instead of You in the Chat')}
					</div>

					<div class="flex items-center gap-2 p-1">
						<Switch
							ariaLabelledbyId="chat-bubble-username-label"
							tooltip={true}
							bind:state={showUsername}
							on:change={() => {
								saveSettings({ showUsername });
							}}
						/>
					</div>
				</div>
			</div>
		{/if}
	</div>

	<div class="flex justify-end text-sm font-medium">
		<button
			class="px-3.5 py-1.5 text-sm font-medium bg-black hover:bg-gray-900 text-white dark:bg-white dark:text-black dark:hover:bg-gray-100 transition rounded-full"
			type="submit"
		>
			{$i18n.t('Save')}
		</button>
	</div>
</form>
