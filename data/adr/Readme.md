ADR Scraping Algorithm
----------------------

The idea here is to get all the LokSabha politicians from adrindia website. For 
each politician we get fields which make sense - 

[This](http://courses.cs.washington.edu/courses/cse544/13sp/final-projects/p12-plarsson.pdf)
is a good analysis of opensource data cleanup tools. Our intent is to follow a 
pattern, so that data cleanup could be :

* Repeatable - i.e we should be able to run the same analysis again.
* Refinable - i.e we might do back to get more information from the site.
* Spiderable - i.e given links on a resource the system can go pull more data.

An additional great effor in this space is [scraperwiki](http://www.scraperwiki.com).
The main use case of scraperwiki is to accurately extract information fromm webpages.
Our goal is to actually combine this efforts.

Now to implementation of adr fetcher. 

* We are interested in all the politicians from LokSabha 2004, 2009. We use
	  the following links
  	* [All Candidates from LokSabha2004](http://myneta.info/loksabha2004/)
  		* The list of candidates if by Constituency -
  			```xslt
	  			$x("//a[contains(@href, 'constituency_id')]")
	  		```
  		* By elections are marked as (a) or (b) -
  				No information on that so far
	  	* [All Candidate from LokSabha2009]
	  		*... 

* For each of these cadidate profiles, we hare the following information 
available for each LokSabha election (as per candidate affadivits):
	* We get following top level attributes
	* Candidate: 
		```xslt
	 		$x("//a[contains(@href, 'candidate_id')]")
		```
		For the below try:
		```xslt
			$x("//table[preceding::h3[contains(text(), 'List of Candidates')]]")
	  			processtable()
		```
	* Party : th(Party), canonicalize_partyname
	* Criminal Cases : th('Criminal Cases'), to_number
	* Education: th('Education'), canoicalize_education
	* Age: th('Age'), shift to birth year
	* Total Assets: th('Total Assets'), ignore span, take number of string
	* Liabilities: th('Liabilities'), ignore span, take number of string
  	* Drilling in deeper we get the following interesting link
  		* Scanned copy of affidavit ```xslt $x("//a[contains(@href, 'scan=original')]") ```
  		  Note: we need to complete the link if its relative.

Now on to implementation of wikipedia linker
* For constituencies -
	* Search wikipedia for {constituency_name} + lok_sabha_constituency 
		and pick the first result. Note: google doesn't let you search and 
		the bing results are low on relevancy.
	* For each wikipedia constituency page fetch the infobox and image if available.

* For politicians -
	* Search wikipedia + {politican_name} + {constituency_name} + lok sabha
		- Search the infobox information[1]:
		```xslt
			$x("//table[contains(concat(' ', normalize-space(@class), ' '), ' infobox ')]")
		```
	* Search twitter for handle using google (not accurate)


Now on to testing and perfecting.

* Of course, we dont want to run the whole algorithm on all links.
	* Try first with one element of each class, do specify depth = 1.
* Generate documents by a YAML dump of ruby hash objects
	YAML.dump({hash_variable_name})
* Look at the the resulting set of documents and run the following tests:
	* ...

Helpful code:
```ruby
	candidates_url = 'http://myneta.info/ls2009/index.php?action=summary&subAction=candidates_analyzed&sort=candidate#summary'

	# Get Nokogiri document we are interested in..
	candidates = Nokogiri::HTML(open(candidates_url))
	table1 = candidates.xpath('//table[preceding::h3[.="Total candidates analyzed by NEW"]]')
	table1.css('tr').each do |candidate|
		candidate.css('td').each do |elements|
			print elements.content
		end
		puts ""
	end
```

[1]: http://stackoverflow.com/questions/1390568/how-to-match-attributes-that-contain-a-certain-string