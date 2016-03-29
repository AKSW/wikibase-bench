#!/usr/bin/env ruby

require 'json'
require 'erb'
require 'net/http'
include ERB::Util


module Wikidata

  # Run a query from a file.
  def self.run_query(endpoint, file, timeout)
    # Setup http
    http = Net::HTTP.new(URI.parse(endpoint).host, URI.parse(endpoint).port)
    http.open_timeout = 60
    http.read_timeout = timeout

    # Setup query
    query = ''
    File.new(file).each_line do |line|
      line.sub!(/#.*$/,'').strip!
      query << (line + ' ') unless line.empty?
    end
    query.strip!

    # Execute the query
    url = "#{endpoint}?query=#{url_encode(query)}"
    begin
      t1 = Time.now
      resp = http.get(URI(url), {'Accept'=>'application/json'})
      t2 = Time.now
      result = {time: t2-t1, body: resp.body, status: resp.code}
    rescue RuntimeError => e
      result = {time: 'timeout', error: e}
    end
  end

  # Count results of a query
  def self.solutions(results)
    if results[:status].to_i == 200
      doc = JSON.parse(results[:body])
      return doc['results']['bindings'].size
    end
  end
  
end
