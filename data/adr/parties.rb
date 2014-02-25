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
  def escapebacktick
    self.gsub(/\`/,"")
  end
end

module PartyCrawler

  class FetchParties
    def initialize
      @parties = YAML.load_file("./parties.yml")
      @use_mongo = false
    end

    def do_get
      @parties.each do |c|
        ch = {}
        title = c[0]
        desc = c[1]["title"]
        if desc
          ch["title"] = title
          ch["desc"] = desc
          #wikipedia
          ch["wikipedia"], ch["summary"], ch["references"], ch["mapimg"] = get_wikipedia(desc)
          #spit
          date = "2013-12-18-"
          fn = date + ch["title"].gsub(" ","-") + ".md"
          print "."
          tmpl = File.read("./parties.md.tmpl")
          liquid = Liquid::Template.parse(tmpl)
          finfo = liquid.render(ch)
          File.open("./parties/"+ fn,'wb'){ |f| f.write(finfo) }
        end
      end
    end

    def goto_web_with_nokogiri(url, opts = {})
      if @use_mongo
        doc = @coll.find_one(:url => url)
        if doc
          content = doc["content"]        
        else
          content = open(url, opts).read
          # word characters seeping in to UTF-8
          content = content.gsub('\x97','')
          content = content.gsub('\xAC','')
          content = content.gsub('\x96','-')
          persist_to_mongo({:url => url, :content => content})
        end
        return Nokogiri::HTML(content)        
      else
        content = open(url, opts).read
        # word characters seeping in to UTF-8
        content = content.gsub('\x97','')
        content = content.gsub('\xAC','')
        content = content.gsub('\x96','-')
        return Nokogiri::HTML(content)
      end
    end

    def get_wikipedia(candidate_name)
      wikilink = ""
      summary = ""
      reference = ""
      photo = ""

      cn = candidate_name.titleize.gsub("\"",'').gsub(" ","_")
      url = "http://en.wikipedia.com/wiki/#{cn}"
  
      begin
        page = goto_web_with_nokogiri(url, "User-Agent" => "Mozilla/5.0")
      rescue OpenURI::HTTPError
        return wikilink, summary, reference, photo
      end
  
      wikilink = url
      print "+"

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
      if check =~ /party/m
      else
        return "","","",""
      end

      # get wikipedia reference links
      links = page.css("span.citation>a")
      reference+= "Wikipedia References\n"
      reference+= "- [Wikipedia]({{page.wikipedia}}), accessed Jan 27, 2014.\n"
      if links.length > 3
        reference+= "- [#{links[0].text.escapebacktick}][wiki1]\n"
        reference+= "- [#{links[1].text.escapebacktick}][wiki2]\n"
        reference+= "- [#{links[2].text.escapebacktick}][wiki3]\n\n"

        reference+= "[wiki1]: " + links[0]["href"] + "\n"
        reference+= "[wiki2]: " + links[1]["href"] + "\n"
        reference+= "[wiki3]: " + links[2]["href"] + "\n"
      else
        ref = ""
        links.each_with_index {|l, idx|
          reference+= "- [#{links[0].text.escapebacktick}][wiki#{idx+1}]\n"
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
          print "i"
          File.open("./images/p/"+ cn + File.extname(uri),'wb'){ |f| f.write(open(uri).read) }
          photo = cn + File.extname(uri)
        end
      end     
      return wikilink, summary, reference, photo
    end

  end #class
end #module

c = PartyCrawler::FetchParties.new
c.do_get