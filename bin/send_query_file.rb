#!/usr/bin/env ruby

require './lib/wikidata.rb'

if ARGV.size != 2
  puts "usage bin/send_query_file.rb <endpoint> <file>"
  exit 1
end

class Server
  attr_reader :endpoint
  def initialize(endpoint)
    @endpoint = endpoint
  end
  def url(query)
    "#{@endpoint}?query=#{url_encode(query)}&analytic=true"
  end
end

server = Server.new(ARGV[0])
query = Wikidata::Query.open(ARGV[1])
puts query
puts
result = query.run(server, 180)
unless result[:status] == 'timeout'
  puts result[:body]
  puts
end
puts result[:time]
puts result[:status]
