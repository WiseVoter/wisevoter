require 'nokogiri'
require 'open-uri'
require 'yaml'
require 'json'

# See Readme.md for process description.

# Note variables starting with capital are constants in Ruby, $ = global, @ = object, @@ = class
RUN_ONCE = false

def get_election_details(fetch_url)
	start_data = Nokogiri::HTML(open(fetch_url))
	constituencies = start_data.xpath("//a[contains(@href, 'constituency_id')]")
	constituencies.each do |constituencies|
		puts constituencies.content
		get_constituency_candidate_details("#{fetch_url}#{constituencies['href']}", constituencies.content)
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
	if info_box_table
		wiki_user_fetch_url = user_fetch_url
	else
		wiki_user_fetch_url = ""
	end
	@constituency_file = <<END
---
layout: constituency
title: #{constituency_name}
map-img-url:
wikipedia-url: #{wiki_user_fetch_url}
date: 2013-08-12
---
## Constituency details
END
	puts @constituency_file
	puts "title:" + "2013-08-12-" + constituency_name.gsub(" ","-") + ".md"
	constituency_file_name = "2013-08-12-" + constituency_name.gsub(" ","-") + ".md"
		File.open("./constituencies/#{constituency_file_name}", "w") do |f|
			f.puts @constituency_file
		end
end

def get_constituency_candidate_details(fetch_url, constituency_name)
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
				element = elements.xpath('.//a/@href')
				row["adr-url"] = "http://myneta.info/ls2009/#{element}"
				row["constituency"] = constituency_name
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
			#curr_objects[index]["twitter.url"] = get_twitter_for_candidate(curr_objects[index]["candidate"])
			#curr_objects[index]["wikipedia.url"] = get_wikipedia_for_candidate(curr_objects[index]["candidate"])
		end
	end
	curr_objects.each do |politician|
		@politician_file = <<END
---
layout: politician
title: #{politician["candidate"]}
constituency: #{politician["constituency"]} 
party: #{politician["party"]}
state: 
education: #{politician["education"]}
photo: 
sex: Male
caste: 
religion: 
crime-accusation-instances: #{politician["criminal_cases"]}
previous-office-title: 
date-of-birth: #{politician["age"]+4}
profession: 
email: 
twitter: #{politician["twitter.url"]}
wikipedia: #{politician["wikipedia.url"]}
adr-url: #{politician["adr-url"]}
website: 
tags: 
candidature: LokSabha2009
networth: #{politician["total_assets"]}
liabilities: #{politician["liabilities"]}
pan: 
date: 2013-08-12
---
## Early Education
Details available at [Wikipedia](http://www.wikipedia.org/wiki/)

## Political Career
Details available at [Wikipedia](http://www.wikipedia.org/wiki/)

## Causes 
Check for the political parties agenda. You can list or vote on your cause at on [VoiceOfTheNation](http://www.voiceofthenation.org).

## Criminal Profile

### Criminal Cases
Based on data from [NoCriminals.org](http://www.nocriminals.org)

## Personal Wealth
Details of assets.

## Track record in Public Office
Check details on [Govcheck](http://www.govcheck.org) for Rajya Sabha and Lok Sabha attendance and work resume. Check details on [MumbaiVotes](http://www.mumbaivotes.org) for local or city body attendance and work resume.
	end
END
		puts @politician_file
		politician_file_name = ("2013-08-12-" + politician["candidate"].gsub(".", "").gsub(" ","-") + ".md")
		File.open("./politicians/#{politician_file_name}", "w") do |f|
			f.puts @politician_file 
		end
	end
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

loksabha2009 = "http://myneta.info/ls2009/"
get_election_details(loksabha2009)


