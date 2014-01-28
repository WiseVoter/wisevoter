require 'nokogiri'
require 'open-uri'
require 'mongo'
require 'logger'
require 'json'
require 'yaml'
require 'english' #For reqular expression $POSTMATCH!
require 'liquid'

class String
	def titleize
		self.gsub(/\b(?<!['`])[a-z]/) { $&.capitalize}
	end
end

module WVCrawler

	class Crawler
		include Mongo
		attr_accessor :log, :start_url
		attr_accessor :ls2009candidates

		def initialize(start_url, use_mongo = true)
			self.log = Logger.new(STDOUT)
			self.log.level = Logger::INFO
			self.ls2009candidates = Array.new
			self.start_url = start_url
			@parties = {}
			@constituencies = {}
			@use_mongo = use_mongo
			if @use_mongo
				@mongo_client = MongoClient.new("127.0.0.1", 27017)
				@db = @mongo_client.db("wisevoter")
				@coll = @db.collection("adr")
				@profile_collection = @db.collection("profiles")
			end
			log.info "initialization complete"
		end

		def get_links
			log.info ">start crawling - \n#{start_url}"
			content = open(start_url).read
			persist_to_mongo({:url => start_url, :content => content})
			c = Nokogiri::HTML(content)
			ns = c.xpath("//a[contains(@href,'constituency_id')]")
			ns.each do | f |
				if !f['href']["http"]
					f = start_url + f['href']
				else
					f = f['href']
				end
				log.info ">>>adding constituency - \n#{f}"
				info = open(f).read
				persist_to_mongo({:url => f, :content => info})
				p = Nokogiri::HTML(info)
				pl = p.xpath("//a[contains(@href,'candidate_id')]")
				pl.each do |politician|
					if !politician['href']["http"]
						phref = start_url + politician['href']
					else
						phref = politician['href']
					end
					log.info ">>>>>>adding candidate - \n#{phref}"
					ls2009candidates.push(phref)
				end
			end
		end

		def print_crawl_list
			ls2009candidates.each { |url|
				puts url
			}
			persist_to_mongo({:url => "http://www.adr.org", 
					:candidate_list => ls2009candidates})
		end

		def persist_to_mongo(doc)
			if @use_mongo
				@coll.insert(doc)
			end
		end

		def persist_profile_to_mongo(title, doc)
			if @use_mongo
				@profile_collection.insert({:title => title, :content => doc})
			end
		end

		def load_candidate_link_random
			if @use_mongo
				doc = @coll.find_one(:url => "http://www.adr.org")
				link = doc["candidate_list"][rand(doc["candidate_list"].length)]
				puts link
				return link
			end
			return ""
		end

		def load_candidate_links
			if @use_mongo
				doc = @coll.find_one(:url => "http://www.adr.org")
				links = doc["candidate_list"]
				return links
			end
			return []
		end

		def goto_web_with_nokogiri(url, opts = {})
			if @use_mongo
				doc = @coll.find_one(:url => url)
				if doc
					content = doc["content"]				
				else
					content = open(url, opts).read
					persist_to_mongo({:url => url, :content => content})
				end
				return Nokogiri::HTML(content)				
			else
				content = open(url, opts).read
				return Nokogiri::HTML(content)
			end
		end

		def crawl_candidate(url)
			p = {}
			page = goto_web_with_nokogiri(url)

			#Try few things with the candidate page.
			#-. Get and print all paragraphs

			title = page.css("h2.main-title").text
			p["title"], is_winner = clean_title(title)
			p["title"] = p["title"].titleize.gsub("\"",'')

			p["profile"] = {}
			p["candidature"] = Array.new
			p["candidature"][0] = {}
			p["candidature"][0]["election"] = "Lok Sabha 2009"
			p["candidature"][0]["myneta-link"] = url
			if (is_winner)
				p["profile"]["current-office-title"] = "Member of Parliament"
				p["candidature"][0]["result"] = "winner"
			end

			constituency = page.css("h5").text
			p["profile"]["constituency"], p["profile"]["state"] = clean_constituency(constituency)
			p["candidature"][0]["constituency"] = p["profile"]["constituency"]

			constituency_val = p["profile"]["constituencies"]
			# orthogonal work to setup constituency in class variable
			if !@constituencies[constituency_val]
				@constituencies[constituency_val] = {}
			end
			@constituencies[constituency_val]["state"] = p["profile"]["state"]
			if !@constituencies[constituency_val]["loksabha-2009"]
				@constituencies[constituency_val]["loksabha-2009"] = {}
			end
			@constituencies[constituency_val]["loksabha-2009"]["candidate-name"] = p["profile"]["title"]
			
			party = page.css("div.grid_2").text
			p["profile"]["party"], p["profile"]["date-of-birth"] = clean_party(party)
			party_val = p["profile"]["party"]
			p["candidature"][0]["party"] = party_val
			if !@parties[party_val]
				@parties[party_val] = {}
			end
			@parties[party_val]["acronym"] = party_val

			education = page.css(".left-margin").text
			level, details = clean_education(education)
			p["profile"]["education-level"] = level
			p["profile"]["education-details"] = details

			networth = page.css(".fullWidth").text
			assets, liabilities = clean_networth(networth)
			p["profile"]["networth"] = {}
			p["profile"]["networth"]["assets"] = assets
			p["profile"]["networth"]["liabilities"] = liabilities
			p["candidature"][0]["assets"] = p["profile"]["networth"]["assets"]
			p["candidature"][0]["liabilities"] = p["profile"]["networth"]["liabilities"]
			
			page.css("a").each { |l|
				case l['href']
				when /expense.php/
					p["candidature"][0]["expenses-link"] = complete_url(l['href'])
				when /scan=original/
					p["candidature"][0]["affidavit-link"] = complete_url(l['href'])
				when /compare_profile/
					p["public_office_track_record"], trs = get_track_record_section(complete_url(l['href']))
					trs.each do |trk|
						p["candidature"].push trk
					end
					# nullify track record info
					p["public_office_track_record"] = ""
				else
				end
			}
			
			p["crime-records"] = []
			criminal_cases_accused = page.at_xpath("//table[preceding::h3[contains(text(), 'Cases where accused')]]")
			if criminal_cases_accused
				criminal_record = "Details of Criminal record \n"
				criminal_cases_accused_rows = criminal_cases_accused.css("tr")
				if criminal_cases_accused_rows
					criminal_cases_accused_rows.each_with_index do |e, idx|
						crime = {}
						if idx != 0
							e.css("td").each_with_index do |t, ix|
								if ix == 1
									criminal_record += " - One criminal accusation with section(s) - "
									crime["crime"] = "accussed"
									criminal_record += (t.text + " ")
									crime["ipc"] = t.text.strip
									criminal_record	+= " for "
								end
								if ix == 2
									criminal_record += (t.text + ".")
									crime["details"] = t.text
								end	
							end
							criminal_record += "\n"
							p["crime-records"].push crime
						end
					end
				end
			end

			criminal_cases_convicted = page.at_xpath("//table[preceding::h3[contains(text(), 'Cases where convicted')]]")
			if criminal_cases_convicted
				criminal_cases_convicted_rows = criminal_cases_convicted.at_css("tr")
				if criminal_cases_convicted_rows 
					criminal_cases_convicted_rows.each_with_index do |e, idx|
						crime = {}
						if idx != 0
								e.css("td").each_with_index do |t, ix|
								if ix == 1
									criminal_record += " - One criminal *conviction* with section(s) - "
									crime["crime"] = "convicted"
									criminal_record += (t.text + " ")
									crime["ipc"] = t.text.strip
									criminal_record	+= " for "
								end
								if ix == 2
									criminal_record += (t.text + ".")
									crime["details"] = t.text
								end	
							end
							criminal_record += "\n"
							p["crime-records"].push crime
						end
					end
				end
			end

			p["profile"]["crime-accusation-instances"] = p["crime-records"].length

			#rebase candidature
			p["candidature"][0]["criminal-cases"] = p["crime-records"].length

			criminal_cases_details = page.at_xpath("//td[./h3[contains(text(), 'Brief Details of IPCs')]]")
			if criminal_cases_details
				criminal_record += "\n#{criminal_cases_details.css("h3").text} \n"
				criminal_record += criminal_cases_details.text.gsub("Brief Details of IPCs", "").gsub(")","). ")
			end
			p["criminal_record"] = ""

			wikilink, summary, refs, photo = get_candidate_wikipedia(p["title"])
			if wikilink
				p["profile"]["wikipedia"] = wikilink
				p["profile"]["photo"] = photo
				p["summary"] = summary
				p["references"] = refs
			end
			return p
		end

		def get_candidate_wikipedia(candidate_name)
			wikilink = ""
			summary = ""
			reference = ""
			photo = ""

			cn = candidate_name.titleize.gsub("\"",'').gsub(" ","_")
			puts cn
			url = "http://en.wikipedia.com/wiki/" + cn
	
			begin
				page = goto_web_with_nokogiri(url, "User-Agent" => "Mozilla/5.0")
			rescue OpenURI::HTTPError
				return wikilink, summary, reference, photo
			end
	
			wikilink = url

			# get summary section
			paras = page.css("p")
			if paras.length > 2
				summary+= paras[0].text + "\n\n"
				summary+= paras[1].text + "\n"
			else
				if paras.length == 1
					summary+= paras[0].text + "\n"
				end
			end
			summary = summary.gsub(/(\[(\d+)\])/m, '')

			#discard wikipedia if the summary doesnt contain the phrase politician
			check = summary.downcase
			if check =~ /politician/m
			else
				return "","","",""
			end

			# get wikipedia reference links
			links = page.css("span.citation>a")
			reference+= "Wikipedia References\n"
			reference+= "- [Wikipedia profile]({{page.profile.wikipedia}}), accessed Jan 27, 2014.\n"
			if links.length > 3
				reference+= "- [#{links[0].text}][wiki1]\n"
				reference+= "- [#{links[1].text}][wiki2]\n"
				reference+= "- [#{links[2].text}][wiki3]\n\n"

				reference+= "[wiki1]: " + links[0]["href"] + "\n"
				reference+= "[wiki2]: " + links[1]["href"] + "\n"
				reference+= "[wiki3]: " + links[2]["href"] + "\n"
			else
				ref = ""
				links.each_with_index {|l, idx|
					reference+= "- [#{links[0].text}][wiki#{idx+1}]\n"
					ref+= "[wiki#{idx+1}]: " + l["href"] + "\n"
				}
				reference+= "\n"
				reference+= ref
			end

			# get wikipedia picture
			pic = page.at_css("table[class='infobox vcard'] a[class='image']")
			if pic
				img_src = pic.at_css("img")["src"]
				# download image
				if img_src
					uri = "http:" + img_src
					puts "saving ", uri
					File.open("./images/"+ cn + File.extname(uri),'wb'){ |f| f.write(open(uri).read) }
					photo = cn + File.extname(uri)
				end
			end
			
			return wikilink, summary, reference, photo
		end



		def spit_profile(profilehash)

			#load the last profile
			date = "2013-12-18-"
			fn = date + profilehash['title'].gsub(" ","-").downcase + ".md"
			puts fn
=begin			
			oldprofile = File.read("../output/politician-name.md")
			if oldprofile =~ /\A(---\s*\n.*?\n?)^(---\s*$\n?)/m
          content = $POSTMATCH
          data = YAML.load($1)
          #puts data["date"]
      end
      summary = get_header("Summary", content)
      education = get_header("Education", content)
      political = get_header("Political Career", content)
      criminal = get_header("Criminal Profile", content)
      personal = get_header("Personal Wealth", content)
      office = get_header("Public Office Track Record", content)
      ref = get_header("References", content)

      #now we have all the old data
			#check for over-writes
			#merge the data and log data conflicts (if any)
			updatedprofilehash = {
				'title' => 'Rahul Gandhi', 
				'profile' => {
					'party' => 'INC',
					'constituency' => 'Amethi'
				},
				'candidature' => [
					{
						'election' => 'Loksabha 2009',
						'filing-link' => 'adr-url',
						'constituency' => 'amethi'
					},
					{
						'election' => 'Loksabha 2009',
						'filing-link' => 'adr-url',
						'constituency' => 'amethi'
					}
				]
		}
=end
			updatedprofilehash = profilehash
			#load the template for new version
			tmpl = File.read("./test.md.tmpl")
			liquid = Liquid::Template.parse(tmpl)
			finfo = liquid.render(updatedprofilehash)
			persist_profile_to_mongo(updatedprofilehash["title"], finfo)
			File.open("./politicians2/"+ fn,'wb'){ |f| f.write(finfo) }
			#spit the new file
		end

		def write_constituency_and_state
			File.open("./constitiencies.yml",'wb'){ |f| f.write(@constituencies.to_yaml) }
			File.open("./parties.yml",'wb'){ |f| f.write(@parties.to_yaml) }
		end

	private
		def clean_education(content)
			content = content.strip.downcase
			level = ""
			details = ""
			if content =~ /((post graduate)|graduate|(12th pass)|(10th pass)|(\dth pass))/
				level = $1
			end
			details = content.gsub(level,"").strip
			return level, details
		end

		def clean_networth(content)
			content = content.strip.downcase
			assets = ""
			liabilities = ""
			if content =~ /(.*?(assets):\s*(rs|rs.)\s*(\S+)\s+.*)/
				assets = $4.strip
			end
			if content =~ /(.*?(liabilities):\s*(rs|rs.)\s*(\S+)\s+.*)/
				liabilities = $4.strip
			end
			return assets, liabilities
		end

		def clean_party(content)
			content = content.strip.downcase
			party = ""
			age = ""
			if content =~ /((.*?)(party):\s*([a-zA-Z0-9]*)\n?(.*)\Z)/m
				party = $4
			end
			if content =~ /((.*?)(age):\s*([a-zA-Z0-9]*)\n?(.*)\Z)/m
				age = $4
			end
			if age 
				age = (2009 - age.to_i) + 1
			end
			return party, age
		end

		def clean_title(content)
			content = content.strip.downcase
			is_winner = false
			if content =~ /(shri|shri\.|smt|smt\.|smti|smti\.|lt|lt\.|lt\. col|lt. col\.|dr|dr\.|adv|adv\.|.*?)(.*)(\(winner\))(.*)/
					is_winner = true
					return $2.strip, is_winner
			end
			if content =~ /(shri|shri\.|smt|smt\.|smti|smti\.|lt|lt\.|lt\. col|lt. col\.|dr|dr\.|adv|adv\.|.*?)(.*)/
				return $2.strip, is_winner
			end
			return content, is_winner
		end

		def clean_constituency(content)
			content = content.strip.downcase
			if content =~ /(.*)(\((.*?)\))/
				return $1.strip, $3.strip.downcase
			end
			return content, ""
		end

		def get_header(hn, content)
			# Remember ? is a "be not greedy" regex matcher
			# Ref. http://regex101.com/ to understand what following does
			if content =~ /^(\#\#?#{hn}\s*\n(.*?\n?))((^\#\#.*?\n)|\Z)/m
				return $2
			end
			return ""
		end
	
		def complete_url(rellink)
			if !(rellink["http"])
				return "http://myneta.info/" + rellink
			else
				return rellink
			end
		end

		def get_track_record_section(url)
			page = goto_web_with_nokogiri(url)
			election_track_records = page.xpath("//table[preceding::h3[contains(text(), 'Comparison')]]")
			keys = [];
			curr_objects = [];
			election_track_records.css('th').each_with_index do |attrib, index|
				keys[index] = attrib.text.gsub(' ', '_').downcase
			end
			i = 0
			election_track_records.css('tr').each_with_index do |election_track_record, index|
				row = {}
				election_track_record.css('td').each_with_index do |elements, index|
					case keys[index]
					when "name"
						row[keys[index]] = elements.content.gsub('!',' ').gsub('\'',' ').split("&nbsp&nbsp")[0].strip.downcase
						element = elements.xpath('.//a/@href')
						row["adr-url"] = "#{element}"
					when "criminal_cases"
						row[keys[index]] = elements.content.to_i
					when "number_of_cases"
						row[keys[index]] = elements.content.to_i
					when "total_assets"
						row[keys[index]] = elements.content.gsub('!',' ').gsub('\'',' ').split("~")[0].strip
					when "total_liabilities"
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
			candidatures = []
			s = "\nElection  | Constituency | Party | Criminal Cases | Education | Assets | Liabilities |\n"
			s += ":----------|:-------------:|:------:|:---------------:|:----------:|:-------|:------------|\n"
			curr_objects.each do |election|
				election_name = election["name"].split(" in ")[1]
				s+= election_name.titleize  + " | "
				s+= election["constituency"] + " | "			
				s+= election["party_code"] + " | "
				s+= election["number_of_cases"].to_s + " | "
				s+= election["education_level"] + " | "
				s+= election["total_assets"] + " | "
				s+= election["total_liabilities"] + " | "
				s+= "\n"
				if election_name != "lok sabha 2009"
					candidature = {}
					candidature["election"] = election_name.titleize
					candidature["myneta-link"] = complete_url(election["adr-url"])
					candidature["constituency"] = election["constituency"].downcase
					candidature["party"] = election["party_code"].downcase
					candidature["criminal-cases"] = election["number_of_cases"]
					candidature["assets"] = election["total_assets"]
					candidature["liabilities"] = election["total_liabilities"]
					candidatures.push candidature
				end

			end
			return s, candidatures
		end

		def yml_to_md_table(yml)

		end

	end #class
end #module

c = WVCrawler::Crawler.new "http://myneta.info/ls2009/"
#c.start
#c.printcrawllist
c.spit_profile(c.crawl_candidate(c.load_candidate_link_random))
=begin
c.load_candidate_links.each_with_index do |l, idx|
	begin
		c.spit_profile(c.crawl_candidate(l))
	rescue
		print "Last Index Was:#{idx}"
	end
end
=end
c.write_constituency_and_state


# Test Cases
#--------------
#c.spit_profile(c.crawl_candidate("http://myneta.info/ls2009/candidate.php?candidate_id=5128"))
# crime candidate
#c.spit_profile(c.crawl_candidate("http://myneta.info/ls2009/candidate.php?candidate_id=8675"))
#c.get_candidate_wikipedia("narendra modi")
#c.spit_profile({'title' => 'Rahul Gandhi'})

