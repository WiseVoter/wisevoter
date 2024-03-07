---
sql:
  politicians: ./data/masterdata.csv
---

# Politicians from 2019 Elections

```sql
SELECT * FROM politicians ORDER BY CrimeAccusationInstances LIMIT 10
```

```js
const dob = view(Inputs.range([1930, 2024], {label: "Date of Birth"}));
```

```sql
SELECT * FROM politicians WHERE DateOfBirth BETWEEN ${dob - 1} AND ${dob + 1};
```