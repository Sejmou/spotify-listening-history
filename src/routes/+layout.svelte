<script>
	import '../app.css';
	import Footer from './Footer.svelte';
</script>

<div class="flex flex-col min-h-[100vh]">
	<main class="flex-1 flex flex-col p-4 w-full mx-0 my-auto box-border">
		<slot />
	</main>
	<Footer />
</div>
