---
title: "Felons and Fiefdoms"
style: wisevoter-style.css
---
# The Disturbing Rise of Criminal Contenders in Maharashtra
```js
import {SQLiteDatabaseClient} from "npm:@observablehq/sqlite";
const db = SQLiteDatabaseClient.open(FileAttachment("data/candidates.sqlite"));
```

The state of Maharashtra, one of India's most populous and politically significant regions, has witnessed a concerning trend in recent years – the increasing presence of criminal elements in the electoral process. As the data reveals, the infiltration of felons into the political arena poses a grave threat to the integrity of the democratic system, undermining the very foundations of governance.

## The Alarming Trend

Our analysis of the data paints a grim picture of the situation in Maharashtra.

**1. Criminal Cases by Party Affiliation**

```js
const criminal_cases_by_party = await db.sql`
  SELECT Party, COUNT(*) AS "Total Candidates", SUM("Criminal Cases") AS "Total Criminal Cases"
  FROM candidates
  WHERE "Criminal Cases" > 0 
  AND "Constituency" IN (
    SELECT Constituency 
    FROM loksabhaconstituencies 
    WHERE State = 'MAHARASHTRA'
  )
  GROUP BY Party
  ORDER BY "Total Criminal Cases" DESC
  LIMIT 10
`;
view(Inputs.table(criminal_cases_by_party))
```
The data reveals that the Vanchit Bahujan Aaghadi and the Indian National Congress (INC) - Sharadchandra, have the highest numbers of candidates with criminal records, underscoring the pervasive nature of this issue across the political spectrum.

```js
Plot.plot({
  marks: [
    Plot.barY(criminal_cases_by_party.slice(0, 5), {x: "Party", y: "Total Criminal Cases", fill: "var(--theme-foreground-focus)"})
  ]
})
```

**2. Top Criminals in Maharashtra**
```js
const top_criminals = await db.sql`
  SELECT Candidate, Party, "Criminal Cases"
  FROM candidates
  WHERE "Constituency" IN (
    SELECT Constituency 
    FROM loksabhaconstituencies 
    WHERE State = 'MAHARASHTRA'
  )
  ORDER BY "Criminal Cases" DESC
  LIMIT 10
`;
view(Inputs.table(top_criminals))
```
The data highlights the alarming presence of the most notorious criminal candidates, with several individuals facing a staggering number of charges.

```js
Plot.plot({
  marks: [
    Plot.barX(top_criminals.slice(0,5), {y: "Candidate", x: "Criminal Cases", fill: "var(--theme-foreground-muted)"})
  ]
})
```

## The Threat to Democracy

The infiltration of criminal elements into the political landscape of Maharashtra poses a grave threat to the foundations of democracy. These individuals, driven by self-interest and a disregard for the rule of law, often use their wealth and influence to buy their way into power, undermining the principles of accountability and representation that are the hallmarks of a healthy democracy.

Moreover, the presence of such candidates in the electoral process creates an environment of fear and intimidation, where voters may be coerced or manipulated into supporting them out of fear of repercussions. This, in turn, erodes public trust in the democratic process and undermines the very legitimacy of the government.

## Conclusion

The data presented in this article paints a disturbing picture of the state of Maharashtra's electoral landscape. The pervasive presence of criminal candidates, backed by powerful political parties, is a clear and present danger to the integrity of the democratic system. It is imperative that policymakers, civil society, and the electorate work together to address this issue and ensure that the voices of the people are heard, and not drowned out by the din of criminal influence and corruption.

---
References:

* Chandra, K. (2004). Why Ethnic Parties Succeed: Patronage and Ethnic Head Counts in India. Cambridge University Press.
* Yadav, Y. (2000). Understanding the Second Democratic Upsurge: Trends of Bahujan Participation in Electoral Politics in the 1990s. Transforming India: Social and Political Dynamics of Democracy, 120-145.
* Vaishnav, M. (2017). When Crime Pays: Money and Muscle in Indian Politics. Yale University Press.

Note: Generated with help of [Claude Haiku](https://www.anthropic.com), [Exposai](https://exposai.wisevoter.org), [Observable](https://www.observablehq.com) and [ADR](https://www.adrindia.org).