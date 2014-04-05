require 'csv'
require 'yaml'

file_name_input = ARGV.first
puts file_name_input
file_name_output = "#{file_name_input}.yml"
data = CSV.read(file_name_input, :headers => true).map(&:to_hash)
File.open(file_name_output, 'w') { |f| f.write(data.to_yaml) }