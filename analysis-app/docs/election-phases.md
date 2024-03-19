---
title: Election Phases 
---

# Election Phases 

## The Phases of Elections

```js
import {phases_timeline} from "./components/timeline.js";
```

```js
const events = FileAttachment("./data/election-phases.json").json();
```

```js
phases_timeline(events, {height: 300})
```

### Phase 1 (Apr )


### India Map
TBD

### Interactivity

Show me all the states in phase 

```js 
const num_phase = view(Inputs.select(["I", "II", "III","IV", "V", "VI", "VII"], {value: "I", label: "Phases"}));
```

```js
Inputs.table(events.filter(e => e.phase === num_phase))
```