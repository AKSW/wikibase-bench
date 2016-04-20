#!/usr/bin/env ruby

require 'csv'
require "#{File.dirname(File.dirname(File.expand_path(__FILE__)))}/lib/wikidata.rb"

if ARGV.size < 3
  puts "Usage: run_bench_all.rb <limit> <queries> <schema> <id-1>...<id-k>"
  exit 1
end

LIMIT   = ARGV[0].to_i
QUERIES = ARGV[1].to_i

case ARGV[2]
when 'all'
  schemas = [:naryrel, :ngraphs, :sgprop, :stdreif, :onaryrel, :ongraphs, :osgprop, :ostdreif]
when 'without-optional'
  schemas = [:naryrel, :ngraphs, :sgprop, :stdreif]
when 'with-optional'
  schemas = [:onaryrel, :ongraphs, :osgprop, :ostdreif]
else
  schemas = [ARGV[2].to_sym]
end

STDOUT.sync = true

log_csv  = File.new('run_bench_all_log.csv', 'a')

quins = Wikidata.read_quins(File.join('data', "quins-all.csv"))

if ARGV.size > 3
  masks = ARGV[3...ARGV.size].map{ |x| x.to_i }
else
  masks = (1..31)
end

schemas.each do |schema|
  masks.each do |i|
    mask = ("%05b" % i).reverse
    puts "Running bench for #{mask} (#{schema})"

    # Start server
    puts "Starting server #{schema} #{mask} #{1+i%2}"
    server = Wikidata::BlazeGraph.new(schema, 1+i%2)
    server.start
    sleep 180

    builder = Wikidata::QueryBuilder.new schema, mask

    start = 500*(i-1)
    (start...(start+QUERIES)).each do |j|
      puts "Executing query #{schema} #{mask} #{j}"
      query = builder.build quins[j], LIMIT
      result = query.run server, 60
      array = [schema, mask, j, result[:time], nil, result[:status]]
      array[4] = Wikidata::Query.solutions(result) if result[:status] == '200'
      log_csv.puts array.to_csv
      log_csv.flush
    end

    # Stop server
    puts 'Stoping server'
    server.stop
    sleep 60
  end
end
