#!/usr/bin/env ruby

# This file contains an script that runs a query against an endpoint.
#
# Arguments are:
#
# - `endpoint`:The endpoint URL.
# - `directory`: The directory that contains the query. It is assumed
#        that several queries are written inside files in this directory.
# - `queryname`: The name of the query to be executed. Each file in the
#        query directory ends with `.sparql`, so the prefix is assumed
#        as the query name.

require 'optparse'
require 'yaml'
require '#{File.dirname(File.dirname(File.expand_path(__FILE__)))}/query_runner.rb'

options = {}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: run_query.rb [options] <endpoint> <directory> <queryname>"

  opts.on("-t", "--timeout TIMEOUT", Integer, "Timeout in seconds") do |timeout|
    options[:timeout] = timeout
  end
end
parser.parse!

parser.parse %w[--help] if ARGV.size != 3

query_runner = QueryRunner.new(ARGV[0], ARGV[1], options)
result = query_runner.run(ARGV[2])
case result
when String
  puts result
else
  puts result[:time]
  puts result[:body]
end
