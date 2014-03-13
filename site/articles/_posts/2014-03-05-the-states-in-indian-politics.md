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
---Lets review the distribution of seats for Indian general election, Lok Sabha. Thanks to [data][1] from election commission of India, its clear that the big states like Uttar Pradesh (80 seats), Maharashtra (48 seats), Bihar (40 seats) and Tamil Nadu (39 seats) help tilt the scale.

In 2009 Lok Sabha elections, [15th Lok Sabha][2], the major national parties were INC (201 seats), BJP (112 seats) with a regional party, SP (22 seats) as a distant third.

Using the data in references and WiseVoter's JSON API, http://www.wisevoter.com/data/2009-general-elections.json, I have created the following map which shows the number of seats allocated to each state and the top three parties in 2009 general elections. Hover on the state with your mouse or touch to get the info!

<div id="map"></div>

<script type="text/javascript" src="http://mbostock.github.com/d3/d3.js"></script>
<script type="text/javascript">
  d3.xml("/assets/images/india-map.svg", "image/svg+xml", function(xml) {
    var tooltip = "<ul id=\"legend\" class=\"list-inline\"><li class=\"state\"></li><li class=\"total\"></li><li><ul class=\"top3parties list-inline\"></ul></li></ul>"
    d3.select("#map").append("div").html(tooltip)
    document.getElementById("map").appendChild(xml.documentElement);
    d3.json("/data/2009-general-elections.json", function(json){
      datum = json;
      datum.forEach(function(data, i){
        d3.select("#" + data.state)
        .on("mouseover", function(d){
          d3.select(this).style({opacity: "0.8"})
          d3.select("#legend .state").text(data.statename)
          d3.select("#legend .total").text(data.total)
          if (data.parties) {
          data.parties.forEach(function(party, i){
              html = "<i class=\"wv wv-party\">party</i>count"
              html = html.replace(/party/g,party.name).replace("count",party.count)
              d3.select("#legend .top3parties").append("li").html(html)
            })
          }
          d3.select("#legend").style("left", (event.layerX + 10) + "px")
          d3.select("#legend").style("top", (event.layerY - 10) + "px")
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

###References
 1. [Election Commission of India][1]
 2. [Wikipedia 15th Lok Sabha][2]

[1]:http://eci.nic.in/press/Phasewise_Statewise_data.pdf
[2]:http://en.wikipedia.org/wiki/List_of_members_of_the_15th_Lok_Sabha_(by_state)