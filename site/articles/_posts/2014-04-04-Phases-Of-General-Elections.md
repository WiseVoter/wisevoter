---
layout: article
title: "Phases of General Election"
author: Vaibhav Bhandari
description: 
headline: 
modified: 2014-04-04
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
excerpt: This article outlines the phases of elections, and which states are going to ballot when in the upcoming 2014 general elections.
---
This article outlines the phases of elections, and which states are going to ballot when in the upcoming 2014 general elections.

<div id="map"></div>

<script type="text/javascript" src="/assets/javascripts/d3.min.js"></script>
<script type="text/javascript">
  d3.xml("/assets/images/india-map.svg", "image/svg+xml", function(xml) {
    var tooltip = "<ul id=\"legend\" class=\"list-inline\"><li class=\"state\"></li><li class=\"total\"></li><li><ul class=\"top3parties list-inline\"></ul></li></ul>"
    d3.select("#map").append("div").html(tooltip)
    document.getElementById("map").appendChild(xml.documentElement);
    d3.json("/data/phases.json", function(json){
      var datum = d3.nest()
        .key(function(d){ return d.state_abbrev})
        .key(function(d){ return d.phase})
        .entries(json)

      datum.forEach(function(data, i){
        d3.select("#" + data.key)
        .on("mouseover", function(d){
          d3.select(this).style({opacity: "0.8"})
          d3.select("#legend .state").text(data.key)
          data.values.forEach(function(party, i){
              html = "<i class=\"wv wv-party\">party</i>count"
              html = html.replace(/party/g,"Phase " + party.key).replace("count", party.values.length)
              d3.select("#legend .top3parties").append("li").html(html)
            })
          d3.select("#legend").style("left", (event.layerX + 10) + "px")
          d3.select("#legend").style("top", (event.layerY + 10) + "px")
          d3.select("#legend").style("display", "inline")
          })
        .on("mouseout", function(d){
          d3.select(this).style({opacity: "1.0"})
          d3.selectAll("#legend .top3parties li").remove()
          d3.select("#legend").style("display", "none")
        })
      })
    })
  });
</script>
<style>
#legend {padding: 5px; border: 1px solid; box-shadow: 3px -3px 2px #888888; display: none; position: absolute; background: #fff; border-radius: 3px}
#india {margin-top: 0px;}
i {background: #222222; color:#F4F0F4; margin: 2px; padding: 3px; }
.state {font-weight: 900;}
.total {color: #bf0000; font-weight: 800;}
</style>

{% for p in site.data.phases | groupBy("phase") %}
  <h3>Phase - {{ loop.key }}</h3>
  <ul>
    {% for s in p | groupBy("state") %}
      <li>{{loop.key}}</li>
      <ul> 
        {% for c in s %}
          <li>{{c.constituency}}</li>
        {% endfor %}
    {% endfor %}
  </ul>
{% endfor %}