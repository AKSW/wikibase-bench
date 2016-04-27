#!/usr/bin/env ruby

USAGE = <<-EOS
Usage: This script run queries against an endpoint using parameters that are
set in the `CONFIG` variable loaded from a config file (for example config.rb).
For example:

$ bin/run_paths_benchmark.rb config/blazegraph_paths.rb
EOS


require 'json'
require 'csv'
require './lib/wikidata.rb'
require "./#{ARGV[0]}"

unless defined? CONFIG
  puts USAGE
  exit 1
end

STDOUT.sync = true

CONFIG[:schemas].each do |schema|
  k = 0
  builder = Wikidata::PathQueryBuilder.new schema

  CONFIG[:path_files].each do |path_file|
    mask = File.basename(path_file).gsub(/.json$/, '')

    # Start server
    server_id = k % CONFIG[:homes].size
    puts "Starting server #{schema} #{mask} #{server_id}"
    server = CONFIG[:engine].new(schema, CONFIG[:homes][server_id])
    server.start
    sleep 180

    # Run the queries for this file
    engine_codename = CONFIG[:engine].name.downcase.sub(/^wikidata::/,'')
    results = File.new("results_#{engine_codename}_#{schema}_#{mask}.csv", 'a')
    results.puts "BEGIN: #{Time.now.to_s}"
    timeouts = 0
    paths = File.new(path_file).to_a
    CONFIG[:queries].each do |j|
      puts "Executing query #{schema} #{mask} #{j}"

      query = builder.build(JSON.parse(paths[j]), CONFIG[:max_solutions])
      result = query.run server, CONFIG[:client_timeout]

      array = [schema, mask, j, result[:time], nil, result[:status]]
      if result[:status] == '200'
        array[4] = Wikidata::Query.solutions(result)
        body_file = File.new("results/solutions/paths/body_#{engine_codename}_#{schema}_#{mask}_#{'%03i' % j}.json", 'w')
        body_file.puts result[:body]
        body_file.close
      end
      query_file = File.new("results/queries/paths/query_#{engine_codename}_#{schema}_#{mask}_#{'%03i' % j}.sparql", 'w')
      query_file.puts query.to_s
      query_file.close
      results.puts array.to_csv
      results.flush
      timeouts += 1 if result[:status] == 'timeout'
      if timeouts == 10
        break
      else
        timeouts = 0
      end
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
