---
title: US Election Fraud in Numbers 
---
Multiple studies and investigations have consistently found that election fraud in the United States is extremely rare. Below is a compilation of data and references that support this conclusion.

# The Brennan Center for Justice studies

The Brennan Center for Justice conducted studies analyzing the prevalence of voter fraud and found minuscule incident rates. The say,  "It is more likely that an American will be struck by lightning than that he will impersonate another voter at the polls".

Findings: Incident rates between 0.0003% and 0.0025%.

```js
// Define the data
const incidentRates = [
  { category: "Fraud Low Estimate", rate: 0.000003 },
  { category: "Fraud High Estimate", rate: 0.000025 },
  { category: "Struck by Lightning", rate: 0.00008 }
];
```

```js
// Create a bar chart using Observable Plot
Plot.plot({
  height: 300,
  width: 500,
  y: {
    label: "Incident Rate (%)",
    tickFormat: d => (d * 100).toFixed(5) + "%"
  },
  marks: [
    Plot.barY(incidentRates, { x: "category", y: "rate", fill: "steelblue" }),
    Plot.ruleY([0])
  ]
})
```
## Reference
- Brennan Center for Justice. "The Truth About Voter Fraud"

# Government Accountability Office (GAO) Report

The GAO reviewed elections and found negligible evidence of in-person voter fraud.

Findings: Out of millions of votes cast, only a handful of fraudulent cases were prosecuted.
```js
// Simulate data
const votesCast = view(Inputs.range([100000000, 180000000], {
   step: 10000,
   value: 160000000,
   label: "Votes cast"
})); // 100 million votes
const fraudulentCases = 30; // Example number of prosecuted cases
```

**Fraud Rate:** ${(fraudulentCases / votesCast * 100).toFixed(6)}%

# Academic Research - News21 investigations
A comprehensive database compiled by journalism students at Arizona State University investigated cases of voter fraud.

Findings: Between 2000 and 2012, out of 146 million registered voters, only 2,068 alleged cases of election fraud were recorded.

```js
// Data
const registeredVoters = 146000000;
const allegedFraudCases = 2068;

// Calculate the rate
const allegedFraudRate = allegedFraudCases / registeredVoters;
```
**Alleged Fraud Rate:** ${(allegedFraudRate * 100).toFixed(6)}%
```js
// Interactive slider to adjust number of cases
const fraudCasesSlider = view(Inputs.range([0, 5000], {
  step: 100,
  value: allegedFraudCases,
  label: "Adjust Alleged Fraud Cases"
}))
```

**Adjusted Fraud Rate:** ${(fraudCasesSlider/ registeredVoters * 100).toFixed(6)}%

```js
const news21barData = [
  { category: "Alleged Fraud Cases", value: fraudCasesSlider },
  { category: "Registered Voters", value: registeredVoters }
];

```

```js
Plot.plot({
  height: 300,
  width: 500,
  y: { label: "Number of People" },
  x: { label: null },
  marks: [
    Plot.barY(news21barData, { x: "category", y: "value", fill: "steelblue" })
  ]
})
```
# Heritage Foundation database
Even the Heritage Foundation, which tracks voter fraud cases, shows very few instances relative to total votes.

Findings: As of 2023, there are 1,402 proven instances of voter fraud since 1982.

```js
// Data
const startYear = 1982;
const endYear = 2023;
const years = endYear - startYear + 1; // Number of years
const totalFraudCases = 1_402;
const averageCasesPerYear = totalFraudCases / years;

// Simulated data over years
const fraudCasesOverYears = Array.from({ length: years }, (_, i) => ({
  year: startYear + i,
  cases: Math.round(Math.random() * 10 + averageCasesPerYear)
}));
```

```js
Plot.plot({
  height: 400,
  width: 700,
  x: { label: "Year" },
  y: { label: "Fraud Cases" },
  marks: [
    Plot.line(fraudCasesOverYears, { x: "year", y: "cases", stroke: "steelblue" }),
    Plot.dot(fraudCasesOverYears, { x: "year", y: "cases", fill: "steelblue" })
  ]
})
```

# Department of Justice Statements
The Department of Justice has not found evidence of widespread voter fraud in recent elections.

Former Attorney General William Barr stated, "To date, we have not seen fraud on a scale that could have affected a different outcome in the election."

```js
const statements = `
To date, we have not seen fraud on a scale that could have affected a different outcome in the election.
No evidence of widespread voter fraud.
Investigations have not found significant irregularities.
`;

// Process the text
const words = statements
  .split(/\W+/)
  .map(d => d.toLowerCase())
  .filter(d => d.length > 3 && !["have", "that", "with", "from", "they", "have", "been", "also", "this", "could"].includes(d));

const wordCounts = Object.entries(words.reduce((counts, word) => {
  counts[word] = (counts[word] || 0) + 1;
  return counts;
}, {})).map(([word, count]) => ({ word, count }));
```

```js
Plot.plot({
  height: 300,
  width: 500,
  marginBottom: 80,
  x: { label: "Word", tickRotate: -45 },
  y: { label: "Frequency" },
  marks: [
    Plot.barY(wordCounts, { x: "word", y: "count", fill: "steelblue" })
  ]
})
```

# Conclusion
The data from multiple reputable sources indicates that election fraud in the United States is extremely rare and has not impacted the outcomes of elections. Interactive analysis demonstrates the minuscule rates of fraud relative to the number of votes cast.

# References
- Brennan Center for Justice. "The Truth About Voter Fraud"
- U.S. Government Accountability Office. "Issues Related to State Voter Identification Laws"
- News21. "Election Fraud in America"
- Heritage Foundation. "A Sampling of Recent Election Fraud Cases from Across the United States" - Associated Press. "Disputing Trump, Barr says no widespread election fraud"
