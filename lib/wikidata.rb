require 'json'
require 'erb'
require 'net/http'
include ERB::Util


module Wikidata

  class Query

    attr_reader :query, :result

    def initialize(query)
      @query = query
    end

    # Create a new query from a file
    def self.open(file_name)
      query = ''
      File.new(file).each_line do |line|
        line.sub!(/#.*$/,'').strip!
        query << (line + ' ') unless line.empty?
      end
      self.new(query.strip)
    end

    # Run a query against an endpoint.
    def run(server, timeout)
      http = Net::HTTP.new(URI.parse(server.endpoint).host, URI.parse(server.endpoint).port)
      http.open_timeout = 60
      http.read_timeout = timeout
      url = server.url(query)

      t1 = Time.now
      begin
        resp = http.get(URI(url), {'Accept'=>'application/json'})
        t2 = Time.now
        result = {time: t2-t1, body: resp.body, status: resp.code}
      rescue RuntimeError => e
        t2 = Time.now
        result = {time: t2-t1, status: 'timeout', error: e}
      end
    end

    # Count solutions of a query
    def self.solutions(results)
      if results[:status].to_i == 200
        doc = JSON.parse(results[:body])
        doc['results']['bindings'].size
      else
        nil
      end
    end

  end

  class QueryBuilder

    def initialize(schema, mask)
      @schema = schema
      @mask   = mask
    end

    def prefixes
      query = ''
      if [:naryrel, :onaryrel, :ngraphs, :ongraphs].include? @schema
        if @mask[1] == '0' or @mask[3] == '0'
          query += 'PREFIX wikibase: <http://wikiba.se/ontology-beta#> '
        end
      end
      if [:naryrel, :onaryrel, :ngraphs, :ongraphs, :sgprop, :osgprop, :stdreif, :ostdreif].include? @schema
        if @mask[0] == '1' or @mask[2] == '1' or @mask[4] == '1'
          query += 'PREFIX wd: <http://www.wikidata.org/entity/> '
        end
        if @mask[1] == '1' or @mask[3] == '1'
          query += 'PREFIX p: <http://www.wikidata.org/prop/> '
        end
      end
      if [:sgprop, :osgprop, :stdreif, :ostdreif].include? @schema
        query += 'PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>'
        if @mask[3] == '0'
          query += 'PREFIX wikibase: <http://wikiba.se/ontology-beta#> '
        end
      end
      if [:naryrel, :onaryrel].include? @schema
        if @mask[1] == '1'
          query += 'PREFIX ps: <http://www.wikidata.org/prop/statement/> '
        end
      end
      query
    end

    def select_variables
      query = ''
      if @mask == '11111'
        query += '* '
      else
        query += '?s '  if @mask[0] == '0'
        query += '?p '  if @mask[1] == '0'
        query += '?o '  if @mask[2] == '0'
        query += '?q '  if @mask[3] == '0'
        query += '?qo ' if @mask[4] == '0'
      end
      query
    end

    def quin_values(quin)
      symbols = {}
      symbols[:s]  = ((@mask[0] == '0') ? '?s'  : "wd:#{quin[0]}")
      symbols[:p]  = ((@mask[1] == '0') ? '?p'  : "p:#{quin[1]}")
      symbols[:ps] = ((@mask[1] == '0') ? '?ps' : "ps:#{quin[1]}")
      symbols[:o]  = ((@mask[2] == '0') ? '?o'  : "wd:#{quin[2]}")
      symbols[:q]  = ((@mask[3] == '0') ? '?q'  : "p:#{quin[3]}")
      symbols[:qo] = ((@mask[4] == '0') ? '?qo' : "wd:#{quin[4]}")
      symbols
    end

    # Generate a graph pattern.
    def graph_pattern(quin)
      s = quin_values(quin)
      query = ''
      case @schema
      when :naryrel
        query += "#{s[:s]} #{s[:p]} ?c . ?c #{s[:ps]} #{s[:o]} ; #{s[:q]} #{s[:qo]} . "
        query += "#{s[:p]} wikibase:propertyValue #{s[:ps]} . " if @mask[1] == '0'
        query += "#{s[:q]} a wikibase:Property . " if @mask[3] == '0'
      when :onaryrel
        if @mask[3] == '1' or @mask[4] == '1'
          query += QueryBuilder.new(@schema, @mask).graph_pattern(quin)
        else
          query += "{ #{s[:s]} #{s[:p]} ?c . ?c #{s[:ps]} #{s[:o]} . "
          query += "#{s[:p]} wikibase:propertyValue #{s[:ps]} . " if @mask[1] == '0'
          query += "} OPTIONAL { "
          query += "?c #{s[:q]} #{s[:qo]} . "
          query += "#{s[:q]} a wikibase:Property . " if @mask[3] == '0'
          query += "}"
        end
      when :ngraphs
        query += "GRAPH ?c { #{s[:s]} #{s[:p]} #{s[:o]} . ?c #{s[:q]} #{s[:qo]} } . "
        query += "#{s[:p]} a wikibase:Property . " if @mask[1] == '0'
        query += "#{s[:q]} a wikibase:Property . " if @mask[3] == '0'
        query += "FILTER (#{s[:s]} != ?c) " if @mask[0] == '0'
      when :ongraphs
        if @mask[3] == '1' or @mask[4] == '1'
          query += QueryBuilder.new(@schema, @mask).graph_pattern(quin)
        else
          query += "{ GRAPH ?c { #{s[:s]} #{s[:p]} #{s[:o]} } . "
          query += "#{s[:p]} a wikibase:Property . " if @mask[1] == '0'
          query += "FILTER (#{s[:s]} != ?c) " if @mask[0] == '0'
          query += "} OPTIONAL { "
          query += "GRAPH ?c { ?c #{s[:q]} #{s[:qo]} } . "
          query += "#{s[:q]} a wikibase:Property . " if @mask[3] == '0'
          query += "}"
        end
      when :sgprop
        query += "#{s[:s]} ?c #{s[:o]} . ?c rdf:singletonPropertyOf #{s[:p]} ; #{s[:q]} #{s[:qo]} . "
        query += "#{s[:q]} a wikibase:Property . " if @mask[3] == '0'
      when :osgprop
        if @mask[3] == '1' or @mask[4] == '1'
          query += QueryBuilder.new(@schema, @mask).graph_pattern(quin)
        else
          query += "{ #{s[:s]} ?c #{s[:o]} . ?c rdf:singletonPropertyOf #{s[:p]} "
          query += "} OPTIONAL { "
          query += "?c #{s[:q]} #{s[:qo]} . "
          query += "#{s[:q]} a wikibase:Property " if @mask[3] == '0'
          query += "}"
        end
      when :stdreif
        query += "?c rdf:subject #{s[:s]} ; rdf:predicate #{s[:p]} ; rdf:object #{s[:o]} ; #{s[:q]} #{s[:qo]} . "
        query += "#{s[:q]} a wikibase:Property . " if @mask[3] == '0'
      when :ostdreif
        if @mask[3] == '1' or @mask[4] == '1'
          query += QueryBuilder.new(@schema, @mask).graph_pattern(quin)
        else
          query += "{ ?c rdf:subject #{s[:s]} ; rdf:predicate #{s[:p]} ; rdf:object #{s[:o]} "
          query += "} OPTIONAL { "
          query += "?c #{s[:q]} #{s[:qo]} . "
          query += "#{s[:q]} a wikibase:Property " if @mask[3] == '0'
          query += "}"
        end
      end
      query
    end

    # Generate a query.
    def build(quin, limit)
      query = [
        prefixes,
        'SELECT', select_variables,
        'WHERE {', graph_pattern(quin), '}',
        'LIMIT', limit
      ].join(' ')
      Query.new query
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

  class DBServer

    attr_reader :endpoint

    def initialize(schema, id=1)
      @schema = schema
      @id     = id
      @home   = "db-#{dbschema}-#{id}"
    end

    def dbschema
      case @schema
      when :naryrel, :onaryrel
        :naryrel
      when :ngraphs, :ongraphs
        :ngraphs
      when :sgprop, :osgprop
        :sgprop
      when :stdreif, :ostdreif
        :stdreif
      end
    end

    def stop
      system "pidof #{@app} | xargs kill"
    end

  end

  class Blazegraph < DBServer

    attr_reader :home

    def initialize(schema, id=1)
      super
      @home = File.join('dbfiles','blazegraph',@home)
      @app  = 'blazegraph'
      @endpoint = 'http://localhost:9999/blazegraph/namespace/kb/sparql'
    end

    def url(query)
      "#{@endpoint}?query=#{url_encode(query)}&timeout=#{CONFIG[:server_timeout]}&analytic=true"
    end

    def properties
      case @schema
      when :ngraphs, :ongraphs
        "quads.properties"
      else
        "triples.properties"
      end
    end

    def start
      fork do
        Dir.chdir @home
        $stdout.reopen("out.log", "w")
        $stderr.reopen("err.log", "w")
        exec(['java', @app],
          '-Xmx6g', '-Dbigdata.propertyFile=server.properties',
          '-jar', 'blazegraph.jar')
      end
    end

  end

  class Virtuoso

    def initialize(schema, id=1)
      super
      @home = File.join('usr', 'local', 'virtuoso-opensource', 'var', 'lib', 'virtuoso', @home)
      @app  = 'virtuoso-t'
      @endpoint = 'http://localhost:8000/sparql/'
    end

    def url(query)
      "#{@endpoint}?query=#{url_encode(query)}"
    end

    def start
      fork do
        Dir.chdir @home
        $stdout.reopen("out.log", "w")
        $stderr.reopen("err.log", "w")
        exec @app
      end
    end

  end

end
