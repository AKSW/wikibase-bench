#!/usr/bin/env ruby

USAGE = <<-EOS
Usage: This script run queries against an endpoint using parameters that are
set in the `CONFIG` variable loaded from a config file (for example config.rb).
For example:

$ bin/run_quins_benchmark.rb config/blazegraph.rb
EOS

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
  puts "loading queries from "+CONFIG[:folder]+"*#{schema}.txt"
  Dir.glob(CONFIG[:folder]+"*#{schema}.txt") do |file|
	templates = [] #the query templates
	template = []
	last_t = nil
	text = File.read(file)
	#CSV.parse("a,0,q0\r\na,1,q1\r\na,1,q2\r\nb,0,qb1") do |row| 
	CSV.parse(text) do |row| 
	#CSV.open(file) do |row| #doesn't work
	  if (row[0]==last_t||last_t==nil)
		template << row
		last_t = row[0]
	  else 
		last_t = row[0]
		templates << template
		template = []
		template << row
	  end
	end
	templates << template
	#puts templates
  
	  templates.each do |template|
		mask = template[0][0]
		#quins_file = CONFIG[:quins].call(mask)
		#puts "Loading #{quins_file}"
		#quins = Wikidata.read_quins quins_file

		# Start server
		server_id = k % CONFIG[:homes].size
		puts "Starting server #{schema} #{mask} #{server_id}"
		server = CONFIG[:engine].new(schema, CONFIG[:homes][server_id]) 
		server.start 
		sleep 60   

		# Run the queries for this mask
		#builder = Wikidata::QuinQueryBuilder.new schema, mask

		engine_codename = CONFIG[:engine].name.downcase.sub(/^wikidata::/,'')
		results = File.new("results_sdw_#{engine_codename}_#{schema}_#{mask}.csv", 'a')
		results.puts "BEGIN: #{Time.now.to_s}"

		timeouts = 0
		counts = 0
		template.each do |queryinstance|
		  j = queryinstance[1]
		  query = URI.decode(queryinstance[2])
		  puts "Executing query #{schema} #{mask} #{j}"
		  #puts query 
		  #query = builder.build quins[j], CONFIG[:max_solutions]   

		  result = query.run server, CONFIG[:client_timeout]
			#puts result
		  array = [schema, mask, j, result[:time], nil, result[:status]]
		  if result[:status] == '200'
			array[4] = Wikidata::Query.solutions(result)
			body_file = File.new("results/solutions/quins/body_sdw_#{engine_codename}_#{schema}_#{mask}_#{'%03i' % j}.json", 'w')
			body_file.puts result[:body]
			body_file.close
		  end
		  query_file = File.new("results/queries/quins/query_sdw_#{engine_codename}_#{schema}_#{mask}_#{'%03i' % j}.sparql", 'w')
		  query_file.puts query.to_s
		  query_file.close
		  results.puts array.to_csv
		  results.flush

		puts counts ##UNDO+
		puts CONFIG[:queries].size
		  counts += 1 
		  if counts == CONFIG[:queries].size
			break
		  end
=begin
		  timeouts += 1 if result[:status] == 'timeout'
		  if timeouts == 10
			break
		  else
			timeouts = 0
		  end
=end
		end

		results.puts "END: #{Time.now.to_s}"
		results.close

		# Stop server
		puts 'Stoping server'
		server.stop

		sleep 20 

		k += 1
	  end
	end
end
