#!/usr/bin/env ruby

require 'csv'
require "#{File.dirname(File.dirname(File.expand_path(__FILE__)))}/lib/wikidata.rb"

if ARGV.size < 5
  puts "Usage: run_bench_distinct.rb <limit> <queries> <schema> <engine> <quins-dir> <id-1>...<id-k>"
  exit 1
end

LIMIT   = ARGV[0].to_i    # Maximun of solutions by query
QUERIES = ARGV[1].to_i    # Maximun of queries per schema
SCHEMA  = ARGV[2].to_sym  # Schema of data and queries (naryrel, onaryrel, ngraphs, ongraphs,...)

case ARGV[3]
when 'blazegraph'
  ENGINE = Wikidata::BlazeGraph
when 'virtuoso'
  ENGINE = Wikidata::Virtuoso
end
  
QDIR    = ARGV[4]         # Directory where quins are

if ARGV.size > 5
  MASKS = ARGV[3...ARGV.size]
else
  MASKS = (1..31).map{ |i| "%05b" % i }
end

k = 1
MASKS.each do |mask|
  quins_file = File.join('data', "quin-patterns-#{mask}.csv")
  puts "Loading #{quins_file}"
  quins = Wikidata.read_quins quins_file

  # Start server
  puts "Starting server #{schema} #{mask} #{1+i%2}"
  server = ENGINE.new(schema, 1+k%2)
  server.start
  sleep 180

  # Stop server
  puts 'Stoping server'
  server.stop
  sleep 60

  k += 1
end



# log_csv  = File.new('experiment_log.csv', 'a')

# endpoint = "http://localhost:8000/sparql/"
# schema = :naryrel
# (1..31).map{ |x| "%05b" % x }.each do |mask|
#   puts "Running bench for #{mask} (#{schema})"

  # Start server
  #sleep 60

  # quins = Wikidata.read_quins(File.join('data', "quin-patterns-#{mask}.csv"))

  # quins.each do |quin|
  #   p quin
  # end
  
  # Run benchmark
  # Dir[File.join('queries',"quins-#{schema}-#{mask}", '*.sparql')].each do |file|
  #   result = Wikidata::run_query(endpoint, file, 60)

  #   log_csv.puts([file,
  #                 result[:time],
  #                 Wikidata::solutions(result),
  #                 result[:status]].to_csv)
    
  #   log_csv.flush
  # end

  # Stop server
  #sytem 'pidof virtuoso-t | xargs kill'
  #sleep 60
#end

#puts Wikidata::solutions(results)
