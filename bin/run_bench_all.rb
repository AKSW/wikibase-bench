#!/usr/bin/env ruby

require 'csv'
require "#{File.dirname(File.dirname(File.expand_path(__FILE__)))}/lib/wikidata.rb"

if ARGV.size != 2
  print "Usage: run_bench_all.rb <limit> <queries>"
  exit 1
end

LIMIT   = ARGV[0].to_i
QUERIES = ARGV[1].to_i

log_csv  = File.new('run_bench_all_log.csv', 'a')

quins = Wikidata.read_quins(File.join('data', "quins-all.csv"))
endpoint = "http://localhost:8000/sparql/"

[:naryrel, :ngraphs].each do |schema|
  (1..31).each do |i|
    mask = ("%05b" % i).reverse
    puts "Running bench for #{mask} (#{schema})"

    # Start server
    puts "Starting server #{schema} #{mask} #{1+i%2}"
    STDOUT.flush
    system "cd /usr/local/virtuoso-opensource/var/lib/virtuoso/db-#{schema}-#{1+i%2} && virtuoso-t"
    sleep 180

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
    
    # Stop server
    puts 'Stoping server'
    STDOUT.flush
    system 'pidof virtuoso-t | xargs kill'
    sleep 60
  end
end
