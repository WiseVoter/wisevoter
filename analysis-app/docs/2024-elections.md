---
title: 2024 Candidates
---
```js
import {SQLiteDatabaseClient} from "npm:@observablehq/sqlite";
const db = FileAttachment("data/candidates.sqlite").sqlite();
```

```js
const politicians = db.sql`SELECT * FROM candidates`;
```

# Show Data
```js
Inputs.table(politicians)
```

Data: ADR, [My Neta](https://www.myneta.org)