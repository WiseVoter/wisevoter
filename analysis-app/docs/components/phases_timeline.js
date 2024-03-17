import * as Plot from "npm:@observablehq/plot";

export function phases_timeline(events, {width, height} = {}) {
  return Plot.plot({
    width,
    height,
    marginTop: 30,
    x: {nice: true, label: null, tickFormat: ""},
    y: {axis: null},
    marks: [
      Plot.ruleX(events, {x: d => new Date(d.date_of_poll), y: "no_of_constituencies", markerEnd: "dot", strokeWidth: 2.5}),
      Plot.ruleY([0]),
      Plot.text(events, {x: d => new Date(d.date_of_poll), y: "no_of_constituencies", text: "date_of_poll", lineAnchor: "bottom", dy: -10, lineWidth: 10, fontSize: 12})
    ]
  });
}
