#!/usr/bin/env ruby

require 'erb'
require 'net/http'
require 'csv'

include ERB::Util

def run_query(endpoint, file, timeout)
  # Setup http
  http = Net::HTTP.new(URI.parse(endpoint).host, URI.parse(endpoint).port)
  http.open_timeout = 60
  http.read_timeout = @timeout.to_i
  http['Accept'] = 'application/json'

  # Setup query
  query = ''
  File.new(file).each_line do |line|
    query << (line.strip + ' ') unless /^#/ === line
  end
  query.strip!

  # Execute the query
  url = "#{endpoint}?query=#{url_encode(query)}"
  begin
    t1 = Time.now
    resp = @http.get(URI(url))
    t2 = Time.now
    result = {time: t2-t1, body: resp.body, status: resp.code}
  rescue RuntimeError => e
    result = {time: 'timeout', error: e}
  end
end

log_csv  = File.new('experiment_log.csv', 'a')

endpoint = "http://localhost:8000/sparql/"
mode = :naryrel
(1..31).map{ |x| "%05b" % x }.each do |mask|
  puts "Running bench for #{mask} (#{mode})"

  # Start server
  sleep 60

  # Run benchmark
  Dir[File.join('queries',"quins-#{mode}-#{mask}", '*.sparlq')].each do |file|
    result = run_query(endpoint, file, 60)

    log_csv.puts [file, result[:time], solutions, result[:status]].to_csv
    log_csv.flush
  end

  # Stop server
  sytem 'pidof virtuoso-t | xargs kill'
  sleep 60
end
