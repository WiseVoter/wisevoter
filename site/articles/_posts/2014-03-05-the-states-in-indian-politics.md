---
layout: article
title: "The States In Indian Politics"
author: Vaibhav Bhandari
modified: 2014-03-05
category: articles
tags: []
image: 
  feature: 
  location: 
  locationlink: 
  credit: 
  creditlink: 
comments: true
readtime: 5
excerpt: This article reviews the distribution of seats in Indian states for national election, and the results of 2009 general elections.
---
This article reviews the distribution of seats in Indian states for national election, and the results of 2009 general elections.

<div id="map"></div>

<script type="text/javascript" src="http://mbostock.github.com/d3/d3.js"></script>
<script type="text/javascript">
  d3.xml("/assets/images/india-map.svg", "image/svg+xml", function(xml) {
    document.getElementById("map").appendChild(xml.documentElement);
    d3.json("/data/2009-general-elections.json", function(json){
      datum = json;
      datum.forEach(function(data, i){
        d3.select("#" + data.state)
        .on('mouseover', function(d){
          d3.select(this).style({opacity: '0.8'})

          })
        .on('mouseout', function(d){
          d3.select(this).style({opacity: '1.0'})
        })
      })
    })
  });
</script>