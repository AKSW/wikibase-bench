#!/usr/bin/env ruby

require 'json'
require 'erb'
require 'net/http'
include ERB::Util


module Wikidata

  # Reading a query from a file.
  def self.read_query(file_name)
    query = ''
    File.new(file).each_line do |line|
      line.sub!(/#.*$/,'').strip!
      query << (line + ' ') unless line.empty?
    end
    query.strip!
  end
  
  # Run a query.
  def self.run_query(endpoint, query, timeout)
    http = Net::HTTP.new(URI.parse(endpoint).host, URI.parse(endpoint).port)
    http.open_timeout = 60
    http.read_timeout = timeout
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

  # Generate a naryrel query from a quin
  def self.generate_query_naryrel(mask, quin, limit)
    query = ''

    # Prefixes
    if mask[1] == '0' or mask[3] == '0'
      query += 'PREFIX wikibase: <http://wikiba.se/ontology-beta#> '
    end
    if mask[0] == '1' or mask[2] == '1' or mask[4] == '1'
      query += 'PREFIX wd: <http://www.wikidata.org/entity/> '
    end
    if mask[1] == '1' or mask[3] == '1'
      query += 'PREFIX p: <http://www.wikidata.org/prop/> '
    end
    if mask[1] == '1'
      query += 'PREFIX ps: <http://www.wikidata.org/prop/statement/> '
    end
    
    # Select clause
    query += 'SELECT '
    if mask == '11111'
      query += '* '
    else
      query += '?s '  if mask[0] == '0'
      query += '?p '  if mask[1] == '0'
      query += '?o '  if mask[2] == '0'
      query += '?q '  if mask[3] == '0'
      query += '?qo ' if mask[4] == '0'
    end
    query += '{ '

    # Pattern variables
    s  = ((mask[0] == '0') ? '?s'  : "wd:#{quin[0]}")
    p  = ((mask[1] == '0') ? '?p'  : "p:#{quin[1]}")
    ps = ((mask[1] == '0') ? '?ps' : "ps:#{quin[1]}")
    o  = ((mask[2] == '0') ? '?o'  : "wd:#{quin[2]}")
    q  = ((mask[3] == '0') ? '?q'  : "p:#{quin[3]}")
    qo = ((mask[4] == '0') ? '?qo' : "wd:#{quin[4]}")
    query += "#{s} #{p} [ #{ps} #{o} ; #{q} #{qo} ] . "

    # Aditional restrictions
    query += "#{p} wikibase:propertyValue #{ps} . " if mask[1] == '0'
    query += "#{q} a wikibase:Property . " if mask[3] == '0'

    # Limit
    query += "} LIMIT #{limit}"
  end

  def self.generate_query_ngraphs(mask, quin, limit)
    query = ''

    # Prefixes
    if mask[1] == '0' or mask[3] == '0'
      query += 'PREFIX wikibase: <http://wikiba.se/ontology-beta#> '
    end
    if mask[0] == '1' or mask[2] == '1' or mask[4] == '1'
      query += 'PREFIX wd: <http://www.wikidata.org/entity/> '
    end
    if mask[1] == '1' or mask[3] == '1'
      query += 'PREFIX p: <http://www.wikidata.org/prop/> '
    end
    
    # Select clause
    query += 'SELECT '
    if mask == '11111'
      query += '* '
    else
      query += '?s '  if mask[0] == '0'
      query += '?p '  if mask[1] == '0'
      query += '?o '  if mask[2] == '0'
      query += '?q '  if mask[3] == '0'
      query += '?qo ' if mask[4] == '0'
    end
    query += '{ '

    # Pattern variables
    c  = ((mask[0] == '0') ? '?c'  : "_:c")
    s  = ((mask[0] == '0') ? '?s'  : "wd:#{quin[0]}")
    p  = ((mask[1] == '0') ? '?p'  : "p:#{quin[1]}")
    o  = ((mask[2] == '0') ? '?o'  : "wd:#{quin[2]}")
    q  = ((mask[3] == '0') ? '?q'  : "p:#{quin[3]}")
    qo = ((mask[4] == '0') ? '?qo' : "wd:#{quin[4]}")
    query += "GRAPH #{c} { #{s} #{p} #{o} . #{c} #{q} #{qo} } . "

    # Aditional restrictions
    query += "#{p} a wikibase:Property . " if mask[1] == '0'
    query += "#{q} a wikibase:Property . " if mask[3] == '0'
    query += "FILTER (#{s} != #{c}) " if mask[0] == '0'
    
    # Limit
    query += "} LIMIT #{limit}"
  end

  # Generate a query from a quin
  def self.generate_query(mode, mask, quin, limit)
    case mode
    when :naryrel
      generate_query_naryrel(mask, quin, limit)
    when :ngraphs
      generate_query_ngraphs(mask, quin, limit)
    end
  end

  # Reads a quins file.
  def self.read_quins(file_name)
    quins = []
    File.new(file_name, 'r').each do |line|
      quins << line.split(' ').map{|x| x.strip }
    end
    quins
  end
end
