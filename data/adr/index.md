Profile Index
=============
Need to figure out a way to gather profiles of a politician from different sources.

* Wikipedia
	** Brief Bio
	** Profile Picture
	** 
* Indian National Congress Website
* Any other sources? - Indian Newspapers?

How the current scrapers works?
------------------------------
The [adr scraper](scrape-adr.rb) algorithm is documented in the code. We need to document the entire scrapping process (govcheck and master csv files). Overtime we can add declarative data cleaning rules.

Identity resolution
~~~~~~~~~~~~~~~~~~~
A central problem in merging all data remains identity resolution. A canonial fullname for a politcian and birth year (or full birthdate) can _may-be_ serve as a good starter. A canonical file needs to be maintained in one place with links or relationships to data-sources (govcheck, adr, wikipedia, twitter etc.) as they are pulled in. So perhaps a canonical identity for a politican be : politician-{full_name| no_salution_lowercase}-{birthyear| yyyy-mm-dd}. Now what is a canonical full_name? It's very hard in India to, check the wikipedia [article](http://en.wikipedia.org/wiki/Indian_name#First_names_and_given_names), perhaps a good topic for a tool on the website! The Indian passport canonicalized full_name as firstname_middlename_surname but it will a garangutan task to format names in this fashion. For now, we use the heuristic of actually using the first full name (two words or more) for a politican encountered as their canonical name and overtime we can add a human check to the identity hash. We will maintain the identity has in the file [politicians-identity-hash.yml] in the format identity (politician-fullname-birthdate), govcheck-url, adr-urls, wikipedia-url, twitter-url).

```ruby
	name.strip('(', ')', '.').lowercase
	salutation = ['shri', 'smti', 'smt', 'dr', 'doctor', 'col', 'prof']
```
Data Scrapping Pipeline
------------------------

	* [politicians-identity-hash.yml]
		** govcheck-url data stored in [spiders/govcheck]
		** 

Defining the data dump
----------------------
The [master csv](output/masterdata.csv) file should have the master data for all politicians, with combined fields from [politicians-identity-hash.yml] and individual files in the [output] directory.