#!/usr/bin/env ruby

require 'optparse'
require 'yaml'
require 'json'
require "#{File.dirname(File.dirname(File.expand_path(__FILE__)))}/lib/query_runner.rb"

options = {
  times: 1
}
parser = OptionParser.new do |opts|
  opts.banner = "Usage: run_query.rb [options] <endpoint> <directory>"

  opts.on("-t", "--timeout TIMEOUT", Integer, "Timeout in seconds") do |timeout|
    options[:timeout] = timeout
  end

  opts.on("-x", "--times TIMES", Integer, "Tines that every query must be sent") do |times|
    options[:times] = times
  end
end
parser.parse!

parser.parse %w[--help] if ARGV.size != 2

query_runner = QueryRunner.new(ARGV[0], ARGV[1], options)

# Sent a query to warm up
# send_query('q00', url_encode('SELECT * WHERE {?s ?p ?o} LIMIT 10'))

options[:times].to_i.times do
  query_runner.queries.each_key do |key|
    STDERR.puts key
    STDERR.flush
    result = query_runner.run(key)
    STDERR.puts result[:time]
    STDERR.flush
  end
end

puts query_runner.queries.to_json

