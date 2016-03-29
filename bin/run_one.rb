#!/usr/bin/env ruby

require 'csv'
require "#{File.dirname(File.dirname(File.expand_path(__FILE__)))}/lib/wikidata.rb"

if ARGV.size != 4
  puts 'Usage: run_one.rb <quins_file> <schema> <mask> <id>'
  exit 1
end

quins_file = ARGV[0]
schema     = ARGV[1].to_sym
mask       = ARGV[2]
id         = ARGV[3].to_i
endpoint   = 'http://localhost:8000/sparql/'

quins = Wikidata::read_quins(quins_file)
query = Wikidata::generate_query(schema, mask, quins[id], 1)

result = Wikidata::run_query(endpoint, query, 60)

if result[:status] == '200'
  puts result[:body]
else
  puts result
end
