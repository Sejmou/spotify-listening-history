// adapted from README at https://www.npmjs.com/package/@duckdb/duckdb-wasm/v/1.28.1-dev106.0
import * as duckdb from '@duckdb/duckdb-wasm';
import { readable } from 'svelte/store';

const JSDELIVR_BUNDLES = duckdb.getJsDelivrBundles();

// Select a bundle based on browser checks
const bundle = await duckdb.selectBundle(JSDELIVR_BUNDLES);

const workerUrl = URL.createObjectURL(
	new Blob([`importScripts("${bundle.mainWorker!}");`], { type: 'text/javascript' })
);

// Instantiate the asynchronus version of DuckDB-wasm
const worker = new Worker(workerUrl);
const logger = new duckdb.ConsoleLogger();
const dbInternal = new duckdb.AsyncDuckDB(logger, worker);

export const db = readable(dbInternal, (set) => {
	dbInternal
		.instantiate(bundle.mainModule, bundle.pthreadWorker)
		.then(() => {
			// revoking the object URL to free up memory
			URL.revokeObjectURL(workerUrl);
			set(dbInternal);
		})
		.catch((err) => {
			console.error(err);
		});
});
