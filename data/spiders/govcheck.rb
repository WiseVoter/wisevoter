require 'uri'
require 'net/http'
require 'rexml/document'

Dir.mkdir("govcheck2") unless File.exists?("govcheck2")
Dir.mkdir("govcheck/images") unless File.exists?("govcheck/images")

(1..741).each { |i|

    url = URI.parse("http://govcheck.net/mp/#{i}/")
    #
    # Follow redirects
    #
    res = nil
    found = false
    until found
        host, port = url.host, url.port if url.host && url.port
        req = Net::HTTP::Get.new(url.path)
        res = Net::HTTP.start(host, port) {|http|  http.request(req) }
        res.header['location'] ? url = URI.parse(res.header['location']) :
        found = true
    end 
    
    name = ''
    state = ''
    constituency = ''
    party = ''
    imgUrl = ''
    sex = ''
    email = ''
    prefixes = [ 'Dr.', 'Smt.', 'Shri', 'Prof.' ]

    res.body.each { |line|
        if line =~ /href="\/state\/\d+\/">([^<]*)/
            state = $1 
        end

        if line =~ /<h1><a href="\/mp[^>]*>([^<]*)/
            puts $1
            name = $1
            idx = $1.index(','); 
            if idx != nil
                names = $1.split(',')
                name = "#{names[1]} #{names[0]}"
            end

            names = name.split(' ')

            # rotate array so that title is first
            idx = 0;
            while !prefixes.index(names[idx]) && idx < names.length 
                idx = idx + 1
            end
            names = names[idx, names.length] + names[0, idx]

            # Strip titles 
            idx = 0
            while prefixes.index(names[idx]) && idx < names.length 
                sex = 'Male' if prefixes[prefixes.index(names[idx])] == 'Shri' 
                sex = 'Female' if prefixes[prefixes.index(names[idx])] == 'Smt.' 
                idx = idx + 1
            end

            name = names[idx, names.length].join ' '

            puts name
        end

        if line =~ /href="\/repregion\/\d+\/">([^<]*)/
            constituency = $1 
        end

        if line =~ /href="\/party\/\d+\/">([^<]*)/
            party = $1
        end    

        if line =~ /<img class="mugshot" src="([^"]*)/
            imgUrl = $1
        end

        if line =~ /    <a href="mailto:([^"]*)/
            email = $1
        end
    }

    if File.exists?("govcheck2/#{name}.dat") then name = name.concat("#{i}") end 

    File.open("govcheck2/#{name}.dat", "w") { |file|
    file << "xxxx \n" \
         << "'''#{name}'''" \
         << "{{#widget:Google_News|query{{PAGENAME}}}}" \
         << "{{Politician \n" \
         << "|Constituency=" << constituency << "\n" \
         << "|Party=" << party << "\n" \
         << "|State=" << state << "\n" \
         << "|Sex=" << sex << "\n" \
         << "|Email=" << email << "\n" \
         << "|Photo=#{name}.jpg" << "\n" \
         << "}} \n" \
         << "yyyy"
    }

#    if imgUrl != '' && imgUrl != 'None'
#        res = Net::HTTP.get_response(URI.parse(imgUrl))
#        File.open("govcheck/images/#{name}.jpg", "w") { |file|
#            file.write(res.body)
#        }
#    end

    puts "Processed: #{i}"
}








