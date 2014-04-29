---
layout: article
title: Women through 15 Lok Sabhas
author: Vaibhav Bhandari
description: 
headline: 
modified: 2014-04-15
category: articles
tags: []
image: 
  feature: 
  location: 
  locationlink: 
  credit: 
  creditlink: 
comments: true
readtime: 3
excerpt: This article visualizes women MPs through last 15 Lok Sabhas. Over the last 15 elections, women representation has improved? Are the core issues addressed? What will the next government do?---This article visualizes women MPs through last 15 Lok Sabhas. Over the last 15 elections, women representation has improved? Are the core issues addressed? What will the next government do?

Using the data in [references][1] and WiseVoter's JSON API, http://www.wisevoter.com/data/mpslist.json, I have created the following map which shows women MPs   by the LokSabha. Hover on the state with your mouse or touch to get the info!

<div class="infographic">
  <h3 class="title">Women through 15 Lok Sabhas</h3>
  <div id="loksabhadetails"></div>
</div>

<script type="text/javascript" src="/assets/javascripts/d3.min.js"></script>
<script type="text/javascript">
  d3.json("/data/mpslist.json", function(json){
    var table = d3.select("#loksabhadetails").append("table"),
    thead = table.append("thead"),
    tbody = table.append("tbody");
    table.attr("class", "details");
    thead.append("th").text("Lok Sabha");
    thead.append("th").text("Total Women Seats");
    var lsabha = d3.nest()
        .key(function(d){ return d["Lok Sabha"]})
        .key(function(d){ return d["Gender"]})
        .rollup(function(leaves) { return leaves.length; })
        .entries(json)
    var tr = tbody.selectAll("tr")
        .data(lsabha)
        .enter()
        .append("tr")
    var cells = tr.selectAll("td")
        .data( function(d){ 
              var num = 0;
              for (var i in d.values) {
                if (d.values[i].key === "Female") {
                    num = d.values[i].values
                }
              }
              console.log(d.key)
              return [d.key, num]
            })
        .enter()
        .append("td").html(function (d) {return d})
    tr.filter(function(d){return d.key === "null" }).remove();
  })
</script>
<style>
#loksabhadetails {margin-top: -20px; display: block;}
.infographic {border: 1px solid #ebebeb; padding: 5px;}
.infographic .title {background: rgba(0,0,0,0.5); color: #fff; padding: 5px; text-align: center;font-weight: 900; margin: 0; font-size: 18px;}
.infographic .legend {margin: 5px; margin-right: 0; border: 1px solid rgba(0,0,0,0.5); background: #fff; padding: 3px; float: right}
#legend {margin: 5px; border: 1px solid; box-shadow: 3px -3px 2px #888888;background: #fff; border-radius: 3px; position: absolute; display: none}
table.details>thead>th {border:2px; padding: 5px; text-align: left; font-weight: 900}
</style>

###References
 1. [Election Commission of India][1]
 2. [Data.gov.in][2]

[1]:http://eci.nic.in/press/Phasewise_Statewise_data.pdf
[2]:http://data.gov.in
