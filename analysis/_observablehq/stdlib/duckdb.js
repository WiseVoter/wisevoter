var L=Object.defineProperty;var s=(t,a)=>L(t,"name",{value:a,configurable:!0});import*as l from"../../_npm/@duckdb/duckdb-wasm@1.28.0/+esm.js";var S=Object.defineProperty,o=s((t,a)=>S(t,"name",{value:a,configurable:!0}),"s");const A=await l.selectBundle({mvp:{mainModule:import.meta.resolve("../../_npm/@duckdb/duckdb-wasm@1.28.0/dist/duckdb-mvp.wasm"),mainWorker:import.meta.resolve("../../_npm/@duckdb/duckdb-wasm@1.28.0/dist/duckdb-browser-mvp.worker.js")},eh:{mainModule:import.meta.resolve("../../_npm/@duckdb/duckdb-wasm@1.28.0/dist/duckdb-eh.wasm"),mainWorker:import.meta.resolve("../../_npm/@duckdb/duckdb-wasm@1.28.0/dist/duckdb-browser-eh.worker.js")}}),C=new l.ConsoleLogger(l.LogLevel.WARNING);let w,f=[];const d=new Map;function E(t,a){a==null?(d.delete(t),w=u.of(),f=Array.from(d,e=>w.then(r=>y(r._db,...e)))):(d.set(t,a),w??=u.of(),f.push(w.then(e=>y(e._db,t,a))))}s(E,"I"),o(E,"registerTable");async function I(t,...a){return(await p()).query(t.join("?"),a)}s(I,"k"),o(I,"sql");async function p(){return await Promise.all(f),await(w??=u.of())}s(p,"b"),o(p,"getDefaultClient");class u{static{s(this,"c")}static{o(this,"DuckDBClient")}constructor(a){Object.defineProperties(this,{_db:{value:a}})}async queryStream(a,e){const r=await this._db.connect();let n,i;try{if(e?.length>0?n=await(await r.prepare(a)).send(...e):n=await r.send(a),i=await n.next(),i.done)throw new Error("missing first batch")}catch(c){throw await r.close(),c}return{schema:i.value.schema,async*readRows(){try{for(;!i.done;)yield i.value.toArray(),i=await n.next()}finally{await r.close()}}}}async query(a,e){const r=await this._db.connect();let n;try{e?.length>0?n=await(await r.prepare(a)).query(...e):n=await r.query(a)}catch(i){throw await r.close(),i}return n}async queryRow(a,e){const r=(await this.queryStream(a,e)).readRows();try{const{done:n,value:i}=await r.next();return n||!i.length?null:i[0]}finally{await r.return()}}async sql(a,...e){return await this.query(a.join("?"),e)}queryTag(a,...e){return[a.join("?"),e]}escape(a){return`"${a}"`}async describeTables(){return(await this.query("SHOW TABLES")).map(({name:a})=>({name:a}))}async describeColumns({table:a}={}){return(await this.query(`DESCRIBE ${this.escape(a)}`)).map(({column_name:e,column_type:r,null:n})=>({name:e,type:v(r),nullable:n!=="NO",databaseType:r}))}static async of(a={},e={}){const r=await g();return e.query?.castTimestampToDate===void 0&&(e={...e,query:{...e.query,castTimestampToDate:!0}}),e.query?.castBigIntToDouble===void 0&&(e={...e,query:{...e.query,castBigIntToDouble:!0}}),await r.open(e),await Promise.all(Object.entries(a).map(([n,i])=>y(r,n,i))),new u(r)}}Object.defineProperty(u.prototype,"dialect",{value:"duckdb"});async function y(t,a,e){if(e=await e,B(e))await b(t,a,e);else if(T(e))await m(t,a,e);else if(Array.isArray(e))await h(t,a,e);else if(D(e))await q(t,a,e);else if("data"in e){const{data:r,...n}=e;T(r)?await m(t,a,r,n):await h(t,a,r,n)}else if("file"in e){const{file:r,...n}=e;await b(t,a,r,n)}else throw new Error(`invalid source: ${e}`)}s(y,"d"),o(y,"insertSource");async function b(t,a,e,r){const n=await e.url();if(n.startsWith("blob:")){const c=await e.arrayBuffer();await t.registerFileBuffer(e.name,new Uint8Array(c))}else await t.registerFileURL(e.name,new URL(n,location).href,4);const i=await t.connect();try{switch(e.mimeType){case"text/csv":case"text/tab-separated-values":return await i.insertCSVFromPath(e.name,{name:a,schema:"main",...r}).catch(async c=>{if(c.toString().includes("Could not convert"))return await k(i,e,a);throw c});case"application/json":return await i.insertJSONFromPath(e.name,{name:a,schema:"main",...r});default:if(/\.arrow$/i.test(e.name)){const c=new Uint8Array(await e.arrayBuffer());return await i.insertArrowFromIPCStream(c,{name:a,schema:"main",...r})}if(/\.parquet$/i.test(e.name))return await i.query(`CREATE VIEW '${a}' AS SELECT * FROM parquet_scan('${e.name}')`);throw new Error(`unknown file type: ${e.mimeType}`)}}finally{await i.close()}}s(b,"p"),o(b,"insertFile");async function k(t,a,e){return await(await t.prepare(`CREATE TABLE '${e}' AS SELECT * FROM read_csv_auto(?, ALL_VARCHAR=TRUE)`)).send(a.name)}s(k,"q"),o(k,"insertUntypedCSV");async function m(t,a,e,r){const n=await t.connect();try{await n.insertArrowTable(e,{name:a,schema:"main",...r})}finally{await n.close()}}s(m,"l"),o(m,"insertArrowTable");async function q(t,a,e){const r=(await import("../../_npm/apache-arrow@15.0.2/+esm.js")).tableFromIPC(e.toArrowBuffer());return await m(t,a,r)}s(q,"L"),o(q,"insertArqueroTable");async function h(t,a,e,r){const n=(await import("../../_npm/apache-arrow@15.0.2/+esm.js")).tableFromJSON(e);return await m(t,a,n,r)}s(h,"h"),o(h,"insertArray");async function g(){const t=await l.createWorker(A.mainWorker),a=new l.AsyncDuckDB(C,t);return await a.instantiate(A.mainModule),a}s(g,"S"),o(g,"createDuckDB");function v(t){switch(t){case"BIGINT":case"HUGEINT":case"UBIGINT":return"bigint";case"DOUBLE":case"REAL":case"FLOAT":return"number";case"INTEGER":case"SMALLINT":case"TINYINT":case"USMALLINT":case"UINTEGER":case"UTINYINT":return"integer";case"BOOLEAN":return"boolean";case"DATE":case"TIMESTAMP":case"TIMESTAMP WITH TIME ZONE":return"date";case"VARCHAR":case"UUID":return"string";default:return/^DECIMAL\(/.test(t)?"integer":"other"}}s(v,"B"),o(v,"getDuckDBType");function B(t){return t&&typeof t.name=="string"&&typeof t.url=="function"&&typeof t.arrayBuffer=="function"}s(B,"R"),o(B,"isFileAttachment");function D(t){return t&&typeof t.toArrowBuffer=="function"}s(D,"N"),o(D,"isArqueroTable");function T(t){return t&&typeof t.getChild=="function"&&typeof t.toArray=="function"&&t.schema&&Array.isArray(t.schema.fields)}s(T,"T"),o(T,"isArrowTable");export{u as DuckDBClient,p as getDefaultClient,E as registerTable,I as sql};
