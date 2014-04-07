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
This interactive graphic outlines the phases of elections, and which states are going to ballot when in the upcoming 2014 general elections. Based on data from election commission of India [1].

<div class="phaseinforgraphic">
  <p>Election Phases</p>
  <div id="phaseselector"></div>
  <div id="phasedetails"></div>
  <div id="map"></div>
</div>

<p><script type="text/javascript" src="/assets/javascripts/d3.min.js"></script></p>
<p><script type="text/javascript">
  var dispatch = d3.dispatch("load", "statechange");
  var phases;
  var phaseDates = {
    "1": "April 7th",
    "2": "April 9th",
    "3A": "April 10th",
    "3B": "April 10th",
    "4": "April 12th",
    "5": "April 17th",
    "6": "April 24th",
    "7": "April 30th",
    "8": "May 7th",
    "9": "May 12th"
  };
  var phaseKeys = ["1","2","3A","3B","4","5","6","7","8","9"];
  dispatch.on("load.menu", function(phaseById){
    var table = d3.select("#phaseselector").append("table"),
        thead = table.append("thead"),
        tbody = table.append("tbody"),
        tr = tbody.append("tr");
    table.attr("class","menu")
    var th = tr.selectAll("td")
        .data(phaseKeys)
        .enter().append("td")
          .attr("class", function(d){
            if (d === phaseById){
              return "active arrow_box";
            }
            return ""
          })
          .on("mouseover", function(d){
            d3.select(this).style({background: "#c2e1f5", opacity: "0.8"})
          })
          .on("mouseout", function(d){
            d3.select(this).style({background: "transparent", opacity: "1.0"})
          })
          .on("click", function(d){
            dispatch.statechange(d, this);
          }) 
          .append("a")
            .text(function(d){ return d;})
    dispatch.on("statechange.menu", function(d, click_handler){
      tr.selectAll(".active").classed("arrow_box", false)
      d3.select(click_handler).attr("class","arrow_box active")
    })
  });
  dispatch.on("load.table", function(phaseById){
    d3.json("/data/phases.json", function(json){
      phases = d3.nest()
        .key(function(d){ return d.phase})
        .key(function(d){ return d.state})
        .entries(json)
      function searchPhases(term) {
        for (var i in phases) {
          if (phases[i].key === term) {
            return phases[i];
          }
        }
      }
      var table = d3.select("#phasedetails").append("table"),
          thead = table.append("thead"),
          tbody = table.append("tbody");
      table.attr("class", "details");
      thead.append("th").text("State");
      thead.append("th").text("Constituencies");
      thead.append("th").text("Total Seats");
      thead.append("th").text("Election Date");
      var tr = tbody.selectAll("tr")
        .data(searchPhases(phaseById).values)
      tr.enter().append("tr");
      var td = tr.selectAll("td")
        .data(function(d) { 
            var constituencies = []
            d.values.forEach(function(r){constituencies.push(r.constituency)})
            return [d.key, constituencies.join(", "), d.values.length, phaseDates[phaseById] 
            ]})
      td.enter().append("td")
        .text(function(d) {return d;});
      dispatch.on("statechange.table", function(id){
        //HACK
        tr.remove();
        tr = tbody.selectAll("tr")
          .data(searchPhases(id).values)
        tr.enter().append("tr")
        tr.exit().remove();
        td = tr.selectAll("td")
          .data(function(d) { 
              var constituencies = []
              d.values.forEach(function(r){constituencies.push(r.constituency)})
              return [d.key, constituencies.join(", "), d.values.length, phaseDates[id] 
              ]});
        td.enter().append("td")
          .text(function(d) {return d;})
        td.exit().remove();
      })
    })
  });
  //start
  dispatch.load("1");
</script>
<style>
.phaseinforgraphic{border: 1px solid #ebebeb; padding: 5px;}
.phaseinforgraphic>p{text-align: center; font-size: 18px; font-weight: 900; text-decoration: underline; color: #fff; background: rgba(0,0,0,0.6); padding: 3px;}
table.menu>tbody>tr>td{border: 0; text-align: center;}
table.menu>tbody>tr>td>a.selected{background: green;}
table.menu>tbody>tr{border: 0;}
table.details {margin-top: 36px;}
table.details>tbody>tr>td {max-width: 300px; word-wrap: break-word;}
.arrow_box {
  position: relative;
  background: #88b7d5 !important;
  border: 4px solid #c2e1f5;
}
.arrow_box:after, .arrow_box:before {
  top: 100%;
  left: 50%;
  border: solid transparent;
  content: " ";
  height: 0;
  width: 0;
  position: absolute;
  pointer-events: none;
}
.arrow_box:after {
  border-color: rgba(136, 183, 213, 0);
  border-top-color: #88b7d5;
  border-width: 30px;
  margin-left: -30px;
}
.arrow_box:before {
  border-color: rgba(194, 225, 245, 0);
  border-top-color: #c2e1f5;
  border-width: 36px;
  margin-left: -36px;
}
table.details>thead>th{text-align: center; font-weight: 900}
#legend {padding: 5px; border: 1px solid; box-shadow: 3px -3px 2px #888888; display: none; position: absolute; background: #fff; border-radius: 3px}
#india {margin-top: 0px;}
i {background: #222222; color:#F4F0F4; margin: 2px; padding: 3px; }
.state {font-weight: 900;}
.total {color: #bf0000; font-weight: 800;}
</style>

## References
- [1], Election Commission of India, accessed April 6, 2014.

[1]: http://eci.nic.in/eci_main1/GE2014/Schedule/Home.htm