<script lang="ts">
	export let className = 'w-4 h-4';
	export let strokeWidth = '1.5';
</script>

<svg
	xmlns="http://www.w3.org/2000/svg"
	fill="none"
	viewBox="0 0 24 24"
	stroke-width={strokeWidth}
	stroke="currentColor"
	class={className}
	aria-hidden="true"
>
	<circle cx="12" cy="12" r="10" stroke-linecap="round" stroke-linejoin="round" />
	<polyline points="12 6 12 12 16 14" stroke-linecap="round" stroke-linejoin="round" />
</svg>
