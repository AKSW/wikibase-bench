#!/usr/bin/env ruby

USAGE = <<-EOS
Usage: This script run queries against an endpoint using parameters that are
set in the `CONFIG` variable loaded from a config file (for example config.rb).
For example:

$ bin/run_quins_benchmark.rb config/blazegraph.rb
EOS

require './lib/wikidata.rb'
require "./#{ARGV[0]}"

unless defined? CONFIG
  puts USAGE
  exit 1
end

STDOUT.sync = true

CONFIG[:schemas].each do |schema|
  k = 0
  CONFIG[:masks].each do |mask|
    quins_file = CONFIG[:quins].call(mask)
    puts "Loading #{quins_file}"
    quins = Wikidata.read_quins quins_file

    # Start server
    puts "Starting server #{schema} #{mask} #{k%2}"
    server = CONFIG[:engine].new(schema, CONFIG[:homes][k%2])
    server.start
    sleep 180

    # Run the queries for this mask
    builder = Wikidata::QueryBuilder.new schema, mask
    results = File.new("results_#{CONFIG[:engine].name.downcase.sub(/^wikidata::/,'')}_#{schema}_#{mask}.csv", 'a')
    results.puts "BEGIN: #{Time.now.to_s}"
    (0...CONFIG[:max_queries]).each do |j|
      puts "Executing query #{schema} #{mask} #{j}"
      query = builder.build quins[j], CONFIG[:max_solutions]
      result = query.run server, CONFIG[:client_timeout]
      array = [schema, mask, j, result[:time], nil, result[:status]]
      array[4] = Wikidata::Query.solutions(result) if result[:status] == '200'
      results.puts array.to_csv
      results.flush
    end
    results.puts "END: #{Time.now.to_s}"
    results.close

    # Stop server
    puts 'Stoping server'
    server.stop
    sleep 10

    k += 1
  end
end
