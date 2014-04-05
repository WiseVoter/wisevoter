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