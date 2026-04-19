<script lang="ts">
	export let size = 'md';
</script>

{#if size === 'md'}
	<div class="flex flex-col gap-2.5 my-2 mx-1">
		<div class="h-3 rounded-md shimmer-bar" style="width: 60%"></div>
		<div class="h-3 rounded-md shimmer-bar" style="width: 82%"></div>
		<div class="h-3 rounded-md shimmer-bar" style="width: 45%"></div>
	</div>
{:else}
	<span
		class="relative flex {size === 'xs' ? 'size-1.5 my-1' : 'size-2 my-1'} mx-1"
	>
		<span
			class="absolute inline-flex h-full w-full animate-pulse rounded-full bg-gray-700 dark:bg-gray-200 opacity-75"
		></span>
		<span
			class="relative inline-flex {size === 'xs' ? 'size-1.5' : 'size-2'} rounded-full bg-black dark:bg-white animate-size"
		></span>
	</span>
{/if}

<style>
	@keyframes size {
		0%,
		100% {
			transform: scale(1);
		}
		50% {
			transform: scale(1.25);
		}
	}

	.animate-size {
		animation: size 1.5s ease-in-out infinite;
	}

	@keyframes shimmer-slide {
		0% {
			background-position: 200% 0;
		}
		100% {
			background-position: -200% 0;
		}
	}

	.shimmer-bar {
		background: linear-gradient(90deg, #e5e5e5 25%, #d4d4d4 50%, #e5e5e5 75%);
		background-size: 200% 100%;
		animation: shimmer-slide 2s linear infinite;
	}

	:global(.dark) .shimmer-bar {
		background: linear-gradient(90deg, #2a2a2e 25%, #3a3a3e 50%, #2a2a2e 75%);
		background-size: 200% 100%;
		animation: shimmer-slide 2s linear infinite;
	}
</style>
