WiseVoter
=========

WiseVoter is a public service project to educated voters on their representatives. 
The current version of the project targets 2014 Indian General elections.

Getting Started
---------------
If you are a journalist, data contributor, editor or developer -- its easy to contribute, just fork the github repository and add or update your changes to the content and submit a patch back. Following is the content structure - 

1. All Articles, are in the directory site/articles/_posts
2. All Politician profiles are in the directory site/politicians/_posts
3. Top level pages are in the directory site/

The content is in [markdown](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) format and its relatively easy to edit in browser on github. 

The site is generated using [Jekyll](http://jekyllrb.com/).

If you are a data hacker, data scientist or developer - in addition to all the above, you can find the site data gathering utilities in the top-level data/ directory. The crawlers are written in ruby and process with python language. The geo-data analysis and visualization is done using [d3js](http://www.d3js.org) and TopoJson.

Data
----
All the associated data for this site is published as [Google fusion tables](http://bit.ly/wv-tables). Currently the crawlers got data from nocriminals.org, govcheck.in and government of India website.

The next data crawling effort underway is to get information from adrindia.org, wikipedia and twitter. Majority of data for the site is aligned on the politician page, each politician has a profile with -
* Personal Details
* Education
* Criminal Background
* Personal Wealth

With the new crawling effort we will soon add information from adrindia, wikipedia and twitter.

Wishlist
--------
* Add capabilities for data wizards, and journalists to create shareable [notebooks](https://github.com/mulesoft/api-notebook)
* Add workflows on getting started for data importers, developers and journalists
* API - an api!

Contributing Guidelines
-----------------------
We are looking for social activists, journalists, data scientists and programmers to help us! All content is under [CC-BY-SA 3.0](http://creativecommons.org/licenses/by-sa/3.0/us/) license, and code is under GPL V3.


Current Contributor(s)
----------------------
* Dewang Mehta
* @vaibhavb
