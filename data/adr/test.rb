require 'open-uri'
require 'mongo'
require 'rake'

include Mongo

def crawl_adr(starting_link, mongourl)
	uri = URI.parse(starting_link)
	str = uri.read()
	client = MongoClient.from_uri(mongourl)
	db = client.db("wisevoter")
	coll = db.collection("adr")
	doc = {"page_content" => str, "data_accessed" => "12/12/2001", 
				"url" => starting_link}
	coll.insert(doc)
end

def get_content()
	client = MongoClient.from_uri("mongodb://wisevoter:wisevoter@ds027419.mongolab.com:27419/wisevoter")
	db = client.db("wisevoter")
	coll = db.collection("adr")
	doc = coll.find_one
	puts doc['page_content']
end

adr = "http://myneta.info/ls2009/"
#crawl_adr(adr,"mongodb://wisevoter:wisevoter@ds027419.mongolab.com:27419/wisevoter")
#crawl_adr(adr, "mongodb://127.0.0.1:27017/wisevoter")
#get_content()


#currdir = fileUtils.sh "echo foo"
#puts FileUtils::RUBY
system 'echo hi'
Dir.chdir("../") do |f|
	#puts FileUtils.pwd()
end
#puts FileUtils.pwd()
sh "echo hello"
#puts currdir