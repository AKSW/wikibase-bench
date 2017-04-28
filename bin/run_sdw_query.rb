#!/usr/bin/env ruby

USAGE = <<-EOS
Usage: This script runs a query against an endpoint using parameters that are
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

if ARGV.size < 2
  print "Usage: run_sdw_query.rb <config.rb> <format> <pattern> <instance> <isalive|keepalive>\n"
  exit 1
end

STDOUT.sync = true

CONFIG[:schemas]=[ARGV[1].to_sym]
CONFIG[:templates]=[ARGV[2]]
instance = ARGV[3]
alive  = ARGV[4] #status wheter db is already online or shall be started (and terminated afterwards) for the query or whete it shall be started but not terminated after query finished

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

		if (CONFIG.key?(:templates) and not( CONFIG[:templates].include? mask))
			next
			#puts "Skipping #{schema} #{mask} #{server_id}"
		end

		# Start server
		
		server_id = k % CONFIG[:homes].size
		server = CONFIG[:engine].new(schema, CONFIG[:homes][server_id]) 
		if(alive!='isalive')
			puts "Starting server #{schema} #{mask} #{server_id}"
			server.start 
			sleep 60 
		end  
		
		# Run the queries for this mask
		#builder = Wikidata::QuinQueryBuilder.new schema, mask

		engine_codename = CONFIG[:engine].name.downcase.sub(/^wikidata::/,'')
		
		#results.puts "BEGIN: #{Time.now.to_s}"

		timeouts = 0
		counts = 0
		template.each do |queryinstance|
		  j = queryinstance[1]
		  if (j!=instance)
			next
		  end
		  results = File.new("sdw_#{engine_codename}_#{schema}_#{mask}_#{'%03i' % j}.csv", 'w')
		  query = URI.decode(queryinstance[2])
		  query = Wikidata::Query.new query
		  puts "Executing query #{schema} #{mask} #{j}"
		  #puts query 
		  #query = builder.build quins[j], CONFIG[:max_solutions]   

		  result = query.run server, CONFIG[:client_timeout]
		  array = [schema, mask, j, result[:time], nil, result[:status]]
		  if result[:status] == '200'
			array[4] = Wikidata::Query.solutions(result)
			body_file = File.new("sdw_#{engine_codename}_#{schema}_#{mask}_#{'%03i' % j}.json", 'w')
			body_file.puts result[:body]
			body_file.close
		  end
		  query_file = File.new("sdw_#{engine_codename}_#{schema}_#{mask}_#{'%03i' % j}.sparql", 'w')
		  query_file.puts query.to_s
		  query_file.close
		  results.puts array.to_csv
		  puts array.to_csv
		  results.flush
		  results.close
		puts timeouts
		#puts CONFIG[:queries].size
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

		#results.puts "END: #{Time.now.to_s}"
		#results.close

		# Stop server
		if((alive!='isalive') || ( alive!='keepalive'))
			puts 'Stoping server'
			server.stop

			sleep 20 
		end

		k += 1
	  end
	end
end

