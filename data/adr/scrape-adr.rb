require 'nokogiri'
require 'open-uri'

=begin
URL = 'http://myneta.info/ls2009/candidate.php?candidate_id=3839'

# Get a Nokogiri::HTML::Document for the page we’re interested in...
doc = Nokogiri::HTML(open(URL))

doc.css('h2.main-title').each do |neta|
	puts (neta.content.downcase)
end
doc.css('h3', ).each do |attribs|
	puts attribs
end
=end

candidates_url = 'http://myneta.info/ls2009/index.php?action=summary&subAction=candidates_analyzed&sort=candidate#summary'


# Get candidates_analyzed
candidates = Nokogiri::HTML(open(candidates_url))
table1 = candidates.xpath('//table[preceding::h3[.="Total candidates analyzed by NEW"]]')
table1.css('tr').each do |candidate|
	candidate.css('td').each do |elements|
		print elements.content
	end
	puts ""
end

