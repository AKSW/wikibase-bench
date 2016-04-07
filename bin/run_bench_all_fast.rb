#!/usr/bin/env ruby

require 'csv'
require "#{File.dirname(File.dirname(File.expand_path(__FILE__)))}/lib/wikidata.rb"

if ARGV.size != 3
  print "Usage: run_bench_all.rb <limit> <queries> <schema>"
  exit 1
end

LIMIT   = ARGV[0].to_i
QUERIES = ARGV[1].to_i

schema = ARGV[2].to_sym

log_csv  = File.new('run_bench_all_log_fast.csv', 'a')

quins = Wikidata.read_quins(File.join('data', "quins-all.csv"))
endpoint = "http://localhost:8000/sparql/"

(1..31).each do |i|
  mask = ("%05b" % i).reverse
  puts "Running bench for #{mask} (#{schema})"
  
  start = 500*(i-1)
  (start...(start+QUERIES)).each do |j|
    puts "Executing query #{schema} #{mask} #{j}"
    query = Wikidata::generate_query(schema, mask, quins[j], LIMIT)
    result = Wikidata::run_query(endpoint, query, 60)
    array = [schema,mask,j,result[:time],nil,result[:status]]
    array[4] = Wikidata::solutions(result) if result[:status] == '200'
    log_csv.puts array.to_csv
    log_csv.flush
  end
end
