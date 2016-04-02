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

  def self.prefixes(schema, mask)
    query = ''
    if [:naryrel, :onaryrel, :ngraphs, :ongraphs].include? schema
      if mask[1] == '0' or mask[3] == '0'
	query += 'PREFIX wikibase: <http://wikiba.se/ontology-beta#> '
      end
      if mask[0] == '1' or mask[2] == '1' or mask[4] == '1'
	query += 'PREFIX wd: <http://www.wikidata.org/entity/> '
      end
      if mask[1] == '1' or mask[3] == '1'
	query += 'PREFIX p: <http://www.wikidata.org/prop/> '
      end
    end
    if [:naryrel, :onaryrel].include? schema
      if mask[1] == '1'
	query += 'PREFIX ps: <http://www.wikidata.org/prop/statement/> '
      end
    end
    query
  end
  
  def self.select_variables(mask)
    query = ''
    if mask == '11111'
      query += '* '
    else
      query += '?s '  if mask[0] == '0'
      query += '?p '  if mask[1] == '0'
      query += '?o '  if mask[2] == '0'
      query += '?q '  if mask[3] == '0'
      query += '?qo ' if mask[4] == '0'
    end
    query
  end

  def self.query_symbols(mask, quin)
    symbols = {}
    symbols[:s]  = ((mask[0] == '0') ? '?s'  : "wd:#{quin[0]}")
    symbols[:p]  = ((mask[1] == '0') ? '?p'  : "p:#{quin[1]}")
    symbols[:ps] = ((mask[1] == '0') ? '?ps' : "ps:#{quin[1]}")
    symbols[:o]  = ((mask[2] == '0') ? '?o'  : "wd:#{quin[2]}")
    symbols[:q]  = ((mask[3] == '0') ? '?q'  : "p:#{quin[3]}")
    symbols[:qo] = ((mask[4] == '0') ? '?qo' : "wd:#{quin[4]}")
    symbols
  end
  
  # Generate a graph pattern.
  def self.graph_pattern(schema, mask, quin)
    s = query_symbols(mask, quin)
    query = ''
    case schema
    when :naryrel
      query += "#{s[:s]} #{s[:p]} ?c . ?c #{s[:ps]} #{s[:o]} ; #{s[:q]} #{s[:qo]} . "
      query += "#{s[:p]} wikibase:propertyValue #{s[:ps]} . " if mask[1] == '0'
      query += "#{s[:q]} a wikibase:Property . " if mask[3] == '0'
    when :onaryrel
      if mask[3] == '1' or mask[4] == '1'
        query += self.graph_pattern(:naryrel, mask, quin)
      else
        query += "{ #{s[:s]} #{s[:p]} ?c . ?c #{s[:ps]} #{s[:o]} . "
        query += "#{s[:p]} wikibase:propertyValue #{s[:ps]} . " if mask[1] == '0'
        query += "} OPTIONAL { "
        query += "?c #{s[:q]} #{s[:qo]} . "
        query += "#{s[:q]} a wikibase:Property . " if mask[3] == '0'
        query += "}"
      end
    when :ngraphs
      query += "GRAPH ?c { #{s[:s]} #{s[:p]} #{s[:o]} . ?c #{s[:q]} #{s[:qo]} } . "
      query += "#{s[:p]} a wikibase:Property . " if mask[1] == '0'
      query += "#{s[:q]} a wikibase:Property . " if mask[3] == '0'
      query += "FILTER (#{s[:s]} != ?c) " if mask[0] == '0'
    when :ongraphs
      if mask[3] == '1' or mask[4] == '1'
        query += self.graph_pattern(:ngraphs, mask, quin)
      else
        query += "{ GRAPH ?c { #{s[:s]} #{s[:p]} #{s[:o]} } . "
        query += "#{s[:p]} a wikibase:Property . " if mask[1] == '0'
        query += "FILTER (#{s[:s]} != ?c) " if mask[0] == '0'
        query += "} OPTIONAL { "
        query += "GRAPH ?c { ?c #{s[:q]} #{s[:qo]} } . "
        query += "#{s[:q]} a wikibase:Property . " if mask[3] == '0'
        query += "}"
      end
    when :sgprop
      query += "#{s[:s]} ?c #{s[:o]} . ?c rdf:singletonPropertyOf ?p ; #{s[:q]} #{s[:qo]} . "
      query += "#{s[:q]} a wikibase:Property . " if mask[3] == '0'
    when :osgprop
      if mask[3] == '1' or mask[4] == '1'
        query += self.graph_pattern(:sgprop, mask, quin)
      else
        query += "{ #{s[:s]} ?c #{s[:o]} . ?c rdf:singletonPropertyOf ?p "
        query += "} OPTIONAL { "
        query += "?c #{s[:q]} #{s[:qo]} . "
        query += "#{s[:q]} a wikibase:Property " if mask[3] == '0'
        query += "}"
      end
    when :stdreif
      query += "?c rdf:subject #{s[:s]} ; rdf:predicate #{s[:p]} ; rdf:object #{s[:o]} ; #{s[:q]} #{s[:qo]} . "
      query += "#{s[:q]} a wikibase:Property . " if mask[3] == '0'
    when :ostdreif
      if mask[3] == '1' or mask[4] == '1'
        query += self.graph_pattern(:stdreif, mask, quin)
      else
        query += "{ ?c rdf:subject #{s[:s]} ; rdf:predicate #{s[:p]} ; rdf:object #{s[:o]} "
        query += "} OPTIONAL { "
        query += "#{s[:q]} #{s[:qo]} . "
        query += "#{s[:q]} a wikibase:Property " if mask[3] == '0'
        query += "}"
      end
    end
    query
  end
  
  # Generate a query.
  def self.generate_query(schema, mask, quin, limit)
    query = <<-EOS
    #{prefixes(schema, mask)}
    SELECT #{select_variables(mask)} {
      #{graph_pattern(schema, mask, quin)}
    } LIMIT #{limit}
    EOS
    query.gsub(/\s+/,' ').strip
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
