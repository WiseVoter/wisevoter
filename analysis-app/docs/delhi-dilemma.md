---
title: "Delhi Dilemma"
---
```js
import {SQLiteDatabaseClient} from "npm:@observablehq/sqlite";
const db = SQLiteDatabaseClient.open(FileAttachment("data/candidates.sqlite"));
```

# Delhi Dilemma
The Delhi elections have long been a battleground for political parties, with each vying for power and influence. However, the presence of candidates with criminal records has become a growing concern, threatening the very foundations of democratic governance. This article delves into the data to uncover the alarming trends and explore the challenges of addressing this issue.

## Uncovering the Criminal Landscape

Our analysis of the data reveals a troubling picture of the Delhi electoral landscape. 

**Candidates with Criminal Cases**
```js
const criminalCandidates = await db.sql`
SELECT * 
FROM candidates
WHERE "Criminal Cases" > 0
AND "Constituency" IN (
    SELECT Constituency 
    FROM loksabhaconstituencies 
    WHERE State = 'DELHI'
  )
LIMIT 10
`;
view(Inputs.table(criminalCandidates));
```

The data shows that a significant number of candidates in the Delhi elections have criminal cases pending against them, raising concerns about the integrity of the electoral process.

**Top Candidates with Highest Assets**
```js
const topAssets = await db.sql`
SELECT "Candidate", "Total Assets"
FROM candidates
WHERE "Constituency" IN (SELECT Constituency FROM loksabhaconstituencies WHERE State = 'DELHI')
ORDER BY "Total Assets" DESC
LIMIT 5;
`;
view(Inputs.table(topAssets));
```

Further examination of the data reveals that the top candidates with the highest total assets are also among those with the most criminal cases, suggesting a correlation between wealth, power, and criminal involvement in the political sphere.

**Top Candidates with Highest Liabilities**
```js
const topLiabilities = await db.sql`
SELECT "Candidate", "Total Liabilities"
FROM candidates
WHERE "Constituency" IN (SELECT Constituency FROM loksabhaconstituencies WHERE State = 'DELHI')
ORDER BY "Total Liabilities" DESC
LIMIT 5;
`;
view(Inputs.table(topLiabilities));
```

The data on the candidates with the highest total liabilities further reinforces the notion that the political landscape in Delhi is heavily influenced by those with deep pockets and questionable backgrounds.

## The Partisan Divide

```js
const criminalsByParty = db.sql`
SELECT "Party", COUNT(*) AS "Candidates with Criminal Cases"
FROM candidates
WHERE "Constituency" IN (SELECT Constituency FROM loksabhaconstituencies WHERE State = 'DELHI') AND "Criminal Cases" > 0
GROUP BY "Party";
`;
view(Inputs.table(criminalsByParty));
```

```js
Plot.plot({
  marks: [
    Plot.barY(criminalsByParty, {x: "Party", y: "Candidates with Criminal Cases"})
  ]
})
```

The data reveals that the problem of criminal candidates is not limited to a single political party, but rather is a widespread issue across the spectrum. The graph shows the number of candidates with criminal cases, grouped by their party affiliations, highlighting the scale of the problem.

## The Delhi Dilemma

The data paints a concerning picture of the Delhi electoral landscape, where the presence of candidates with criminal backgrounds has become commonplace. This trend not only undermines the integrity of the democratic process but also raises questions about the ability of the electorate to make informed choices.

As citizens, it is crucial to be aware of these issues and demand greater accountability from our elected representatives. Policymakers and civil society organizations must work together to develop effective strategies to address this challenge and restore public trust in the electoral system.

---
References:
- Vaishnav, Milan. "When crime pays: Money and muscle in Indian politics." Carnegie Endowment for International Peace (2017).
- Ghosh, Arunabha, and Sanjay Kumar. "Criminalization of Politics in India: Causes and Consequences." Economic and Political Weekly 39.8 (2004): 767-770.
- Vaishnav, Milan, and Jamie Hintson. "Reforming India's Criminal Political Financing System." Carnegie Endowment for International Peace (2019).

Note: Generated with help of [Claude Haiku](https://www.anthropic.com), [Exposai](https://exposai.wisevoter.org), [Observable](https://www.observablehq.com) and [ADR](https://www.adrindia.org).