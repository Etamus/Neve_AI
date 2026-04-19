<script lang="ts">
	import LocalModels from '$lib/components/workspace/LocalModels.svelte';
	import { WEBUI_NAME } from '$lib/stores';
	import i18n from '$lib/i18n';
</script>

<svelte:head>
	<title>{$i18n.t('Models')} • {$WEBUI_NAME}</title>
</svelte:head>

<LocalModels />
