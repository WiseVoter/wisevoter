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

# Numbers

<!-- Cards with big numbers -->
```js echo
const criminals = await db.sql`SELECT * FROM candidates WHERE "Criminal Cases" > 0;`
```
<div class="grid grid-cols-4">
  <div class="card">
    <h2>Criminals</h2>
    <span class="big">${criminals.length}</span>
  </div>
</div>