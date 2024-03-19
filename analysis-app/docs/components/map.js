import * as Plot from "npm:@observablehq/plot";
import {geoNaturalEarth1}from "npm:d3-geo";

// Function to fetch GeoJSON data of India
async function fetchIndiaGeoJSON() {
  const response = await fetch('https://raw.githubusercontent.com/PublicaMundi/MappingAPI/master/data/geojson/us-states.json');
  return response.json();
}

// Function to create the map plot
export async function indiaMap(width = 300) {
  const nation = await fetchIndiaGeoJSON(); // Fetch the GeoJSON data
  console.log(nation);

  return Plot.plot({
    width,
    height: width * 0.6,
    projection: {
      type: "albers",
      insetTop: 15
    },
    marks: [
      Plot.geo(nation, {
        fill: "currentColor",
        fillOpacity: 0.2,
        stroke: "black"
      }),
    ]
  });
}


