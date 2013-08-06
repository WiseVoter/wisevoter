require 'uri'
require 'net/http'
require 'rexml/document'

(1..400).each { |i|
    url = URI.parse('http://124.153.101.158')
    res = Net::HTTP.start(url.host, url.port) { |http|
            http.get("/bindass/contest/ichange/cand_details.php?candid=#{i}");
    }

    name = ''
    state = ''
    constituency = ''
    party = ''
    res.body.each { |line|
        if line =~ /State : ([^<]*)/
            state = $1 
        end

        if line =~ /<h4>([^<]*)</
            name = $1
        end

        if line =~ /Constituency : ([^<]*)/
            constituency = $1 
        end

        if line =~ /Party Name :<\/h3>([^<]*)<h3>/
            party = $1
        end    

    }

    File.open("ichange#{i}.out", "w") { |file|
        file << name << "|" << state << "|" << party << "|" << constituency
    }

    puts "Processed: #{i}"
}



