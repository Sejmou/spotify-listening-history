<script lang="ts">
	import { Button } from '$lib/components/ui/button';
	import { Textarea } from '$lib/components/ui/textarea';
	import { db } from '$lib/duckdb';
	import * as Card from '$lib/components/ui/card';
	import * as Table from '$lib/components/ui/table';

	let query = '';
	// key == column name, value == array of values
	let result: { columns: string[]; data: Record<string, any>[] } | null = null;

	async function getResult(query: string) {
		const conn = await $db.connect();
		// could type the result object(s) here if query were known statically (i.e. using {count: Int } instead of any for query "SELECT COUNT(*) FROM ...")
		const resultTable = await conn.query<any>(query);
		const columns = resultTable.schema.fields.map((d) => d.name);
		const data: Record<string, any[]> = {};
		columns.forEach((col) => {
			data[col] = resultTable.getChild(col)!.toJSON();
		});
		console.log(data);
		result = { columns, data: recordToArrayOfObjects(data) };

		await conn.close();
	}

	function recordToArrayOfObjects(record: Record<string, any[]>) {
		const keys = Object.keys(record);
		if (keys.length === 0) {
			console.warn('No keys found in record');
			return [];
		}

		// Assuming all arrays are of equal length, use the length of the first array
		const length = record[keys[0]!]!.length;
		const result: Record<string, any>[] = [];

		for (let i = 0; i < length; i++) {
			const obj: Record<string, any> = {};
			keys.forEach((key) => {
				obj[key] = record[key]![i];
			});
			result.push(obj);
		}

		return result;
	}
</script>

<svelte:head>
	<title>My Spotify Data</title>
</svelte:head>

<div class="flex flex-col gap-4 max-w-screen-xl mx-auto">
	<h1 class="scroll-m-20 text-4xl font-extrabold tracking-tight lg:text-5xl">Welcome!</h1>
	<p class="leading-7">
		Some day you will be able to import and explore the data from your personal Spotify data dump
		ZIP-file here.
	</p>
	<Card.Root>
		<Card.Header>
			<Card.Title>DuckDB Demo</Card.Title>
			<Card.Description
				>Enter a DuckDB SQL query. It is executed directly in your browser using <a
					class="link"
					href="https://github.com/duckdb/duckdb-wasm"
					target="_blank">duckdb-wasm</a
				>!</Card.Description
			>
		</Card.Header>
		<Card.Content class="flex flex-col gap-2">
			{#if $db}
				<Textarea placeholder="Your query" bind:value={query} />
			{:else}
				<p>Loading...</p>
			{/if}
		</Card.Content>
		<Card.Footer>
			<Button on:click={() => getResult(query)}>Run</Button>
		</Card.Footer>
	</Card.Root>
	{#if result}
		<Card.Root>
			<Card.Header>
				<Card.Title>Query Result</Card.Title>
			</Card.Header>
			<Card.Content class="flex flex-col gap-2">
				<Table.Root>
					<Table.Caption>The result of your query.</Table.Caption>
					<Table.Header>
						<Table.Row>
							{#each result.columns as col}
								<Table.Head>{col}</Table.Head>
							{/each}
						</Table.Row>
					</Table.Header>
					<Table.Body>
						{#each result.data as row}
							<Table.Row>
								{#each result.columns as col}
									<Table.Cell>{row[col]}</Table.Cell>
								{/each}
							</Table.Row>
						{/each}
					</Table.Body>
				</Table.Root>
			</Card.Content>
		</Card.Root>
	{/if}
</div>
