require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'json'

=begin
The idea here is to get all the LokSabha politicians from adrindia website. For 
each politician we get fields which make sense - 

[This](http://courses.cs.washington.edu/courses/cse544/13sp/final-projects/p12-plarsson.pdf)
is a good analysis of opensource data cleanup tools. Our intent is to follow a 
pattern, so that data cleanup could be -
	
	* Repeatable - i.e we should be able to run the same analysis again.
	* Refinable - i.e we might do back to get more information from the site.
	* Spiderable - i.e given links on a resource the system can go pull more data.

An additional great effor in this space is [scraperwiki](http://www.scraperwiki.com).
The main use case of scraperwiki is to accurately extract information fromm webpages.
Our goal is to actually combine this efforts.

Now to implementation of adr fetcher. 

	* We are interested in all the politicians from LokSabha 2004, 2009. We use
	  the following links
	  	** [All Candidates from LokSabha2004](http://myneta.info/loksabha2004/)
	  		*** The list of candidates if by Constituency -
		  			$x("//a[contains(@href, 'constituency_id')]")
	  		*** By elections are marked as (a) or (b) -
	  				No information on that so far

	  	** [All Candidate from LokSabha2009]
	  		*** 

	* For each of these cadidate profiles, we hare the following information 
	  available for each LokSabha election (as per candidate affadivits):
	  	** We get following top level attributes
	  		- Candidate: $x("//a[contains(@href, 'candidate_id')]")
	  		For the below try:
	  		$x("//table[preceding::h3[contains(text(), 'List of Candidates')]]")
	  			processtable()
	  		- Party : th(Party), canonicalize_partyname
	  		- Criminal Cases : th('Criminal Cases'), to_number
	  		- Education: th('Education'), canoicalize_education
	  		- Age: th('Age'), shift to birth year
	  		- Total Assets: th('Total Assets'), ignore span, take number of string
	  		- Liabilities: th('Liabilities'), ignore span, take number of string

	  	** Drilling in deeper we get the following interesting link
	  		- Scanned copy of affidavit $x("//a[contains(@href, 'scan=original')]")
	  		  Note: we need to complete the link if its relative.

Now on to implementation of wikipedia linker
	* For constituencies -
		** Search wikipedia for {constituency_name} + lok_sabha_constituency 
			and pick the first result. Note: google doesn't let you search and 
			the bing results are low on relevancy.

	* For politicians -
		** Search wikipedia + {politican_name} + {constituency_name} + lok sabha
			- Search the infobox information[1]:
				$x("//table[contains(concat(' ', normalize-space(@class), ' '), ' infobox ')]")
				-- 
		** Search twitter for handle


Now on to testing and perfecting.
	* Of course, we dont want to run the whole algorithm on all links.
	* Try first with one element of each class, do specify depth = 1.
	* Generate documents by a YAML dump of ruby hash objects
		YAML.dump({hash_variable_name})
	* Look at the the resulting set of documents and run the following tests:
		** -

Helpful code:
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

[1]: http://stackoverflow.com/questions/1390568/how-to-match-attributes-that-contain-a-certain-string

=end

# Note variables starting with capital are constants in Ruby, $ = global, @ = object, @@ = class
RUN_ONCE = true

def get_election_details(fetch_url)
	start_data = Nokogiri::HTML(open(fetch_url))
	constituencies = start_data.xpath("//a[contains(@href, 'constituency_id')]")
	constituencies.each do |constituencies|
		puts constituencies.content
		get_constituency_candidate_details("#{fetch_url}#{constituencies['href']}")
		get_constituency_wikipedia(constituencies.content)
		break if RUN_ONCE
	end
end

# DONT USE - doesn't work that well
def get_constituency_google(constituency_name)
	query = URI::encode(constituency_name.gsub(' ', '_'))
	fetch_url = "https://www.google.com/search?q=wikipedia+#{query}+(Lok_Sabha_constituency)"
	puts fetch_url
	data = Nokogiri::HTML(open(fetch_url, "User-Agent" => "Mozilla/5.0"))
	links = data.xpath("//cite[./b[contains(text(), 'wikipedia')]]")
	links.each do |link|
		puts link.content
	end
end

def get_constituency_wikipedia(constituency_name)
	query = URI::encode(constituency_name.gsub(' ','_').gsub('&','and'))
	fetch_url = "http://en.wikipedia.org/w/api.php?action=query&prop=revisions&titles=#{query}_(Lok_Sabha_constituency)&rvprop=content&format=json"
	user_fetch_url = "http://en.wikipedia.org/wiki/#{query}_(Lok_Sabha_constituency)"
	# TODO: Migrate to wikipedia API at some point, until then scrape
	start_data = Nokogiri::HTML(open(user_fetch_url, "User-Agent" => "Mozilla/5.0"))
	info_box_table = start_data.xpath("//table[contains(concat(' ', normalize-space(@class), ' '), ' infobox ')]")
	puts "Constituency Wikipedia: " + user_fetch_url if info_box_table
end

def get_constituency_candidate_details(fetch_url)
	start_data = Nokogiri::HTML(open(fetch_url))
	candidates = start_data.xpath("//table[preceding::h3[contains(text(), 'List of Candidates')]]")
	keys = [];
	curr_objects = [];
	candidates.css('th').each_with_index do |attrib, index|
		keys[index] = attrib.text.gsub(' ', '_').downcase
	end
	# HACK
	i = 0
	candidates.css('tr').each_with_index do |candidate, index|
		row = {}
		candidate.css('td').each_with_index do |elements, index|
			case keys[index]
			when "candidate"
				row[keys[index]] = elements.content.gsub('!',' ').gsub('\'',' ').split("&nbsp&nbsp")[0].strip.downcase
				if elements.content.gsub('!',' ').gsub('\'',' ').split("&nbsp&nbsp")[1]
					row["winner"] = true
				end
			when "criminal_cases"
				row[keys[index]] = elements.content.to_i
			when "total_assets"
				row[keys[index]] = elements.content.gsub('!',' ').gsub('\'',' ').split("~")[0].strip
			when "liabilities"
				row[keys[index]] = elements.content.gsub('!',' ').gsub('\'',' ').split("~")[0].strip
			when "age"
				row[keys[index]] = elements.content.to_i
			else
				row[keys[index]] = elements.content.strip
			end
		end
		unless row.empty? 
			curr_objects[i] = row 
			i = i + 1
		end
	end
	curr_objects.each_with_index do |elements, index|
		if (index > 0)
			curr_objects[index]["twitter.url"] = get_twitter_for_candidate(curr_objects[index]["candidate"])
			curr_objects[index]["wikipedia.url"] = get_wikipedia_for_candidate(curr_objects[index]["candidate"])
		end
	end
	puts curr_objects.to_yaml
end

def get_twitter_for_candidate(candidate_name)
	query = URI::encode(candidate_name)
	fetch_url = "https://www.google.com/search?q=twitter+#{query}"
	data = Nokogiri::HTML(open(fetch_url, "User-Agent" => "Mozilla/5.0"))
	links = data.xpath("//cite[./b[contains(text(), 'twitter')]]")
	links.each do |link|
	end
	if links.size() > 0
		first_link = links[0].content
	else
		""
	end
end

def get_wikipedia_for_candidate(candidate_name)
	query = URI::encode(candidate_name)
	fetch_url = "https://www.google.com/search?q=wikipedia+#{query}+lok_sabha_candidate"
	data = Nokogiri::HTML(open(fetch_url, "User-Agent" => "Mozilla/5.0"))
	links = data.xpath("//cite[./b[contains(text(), 'wikipedia')]]")
	links.each do |link|
	end
	if links.size() > 0
		first_link = links[0].content
	else
		""
	end
end

loksabha2004 = "http://myneta.info/loksabha2004/"
get_election_details(loksabha2004)


