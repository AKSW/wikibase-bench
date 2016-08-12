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

    def to_s
      @query
    end

    # Create a new query from a file
    def self.open(file_name)
      query = ''
      File.new(file_name).each_line do |line|
        line.sub!(/^#.*$/,'')
        line.strip!
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
        begin
          doc = JSON.parse(results[:body])
          return doc['results']['bindings'].size
        rescue
          return nil
        end
      else
        return nil
      end
    end

  end

  class QueryBuilder

    @@prefixes = {
      wikibase: '<http://wikiba.se/ontology-beta#>',
      wd: '<http://www.wikidata.org/entity/>',
      rdf: '<http://www.w3.org/1999/02/22-rdf-syntax-ns#>',
      p: '<http://www.wikidata.org/prop/>',
      ps: '<http://www.wikidata.org/prop/statement/>'
    }

    def prefix(namespace)
      "PREFIX #{namespace}: #{@@prefixes[namespace]}"
    end

  end

  class PathQueryBuilder < QueryBuilder

    def initialize(schema)
      @schema = schema
    end

    def prefixes
      case @schema
      when :naryrel
        prefix_list = [:wd, :p, :ps, :wikibase]
      when :ngraphs
        prefix_list = [:wd, :p]
      when :rdr ,:ordr
        prefix_list = [:wd, :p, :wikibase]
      when :sgprop
        prefix_list = [:wd, :rdf, :p]
      when :stdreif
        prefix_list = [:wd, :p, :rdf]
      end
      prefix_list.map { |namespace| prefix(namespace) }
    end

    def resource(name)
      name[0] == '?' ? name : "wd:#{name}"
    end

    def statement(claim_var, entity, property, valueitem)
      case @schema
      when :naryrel
        [
          resource(entity), "p:#{property}", claim_var, '.',
          claim_var, "ps:#{property}", resource(valueitem), '.'
        ]
      when :ngraphs
        [
          "GRAPH #{claim_var} { #{resource(entity)} p:#{property} #{resource(valueitem)}} ."
        ]
      when :sgprop
        [
          resource(entity), claim_var, resource(valueitem), '.',
          claim_var, 'rdf:singletonPropertyOf', "p:#{property}", '.'
        ]
      when :stdreif
        [
          claim_var, 'rdf:subject', resource(entity), '.',
          claim_var, 'rdf:predicate', "p:#{property}", '.',
          claim_var, 'rdf:object', resource(valueitem), '.'
        ]
      end
    end

    def build(path, limit)
      select_clause = []
      graph_pattern = []
      (0...path.size).each do |i|
        entity  = "?x#{i}"
        select_clause << entity
        node = path[i]
        claims = node['claims']
        (0...claims.size).each do |j|
          claim = claims[j]
          property = claim[0]
          case claim[1]
          when 0, 1
            valueitem = "?x#{i}y#{j}"
            select_clause << valueitem if claim[1] == 1
          else
            valueitem = claim[1]
          end
          claim_var = "?claim_x#{i}y#{j}"
          graph_pattern << statement(claim_var, entity, property, valueitem)
        end
        unless node['property'].nil?
          graph_pattern << statement("?claim_x#{i}", entity, node['property'], "?x#{i+1}")
        end
      end

      query = prefixes + ['SELECT'] + select_clause + ['WHERE', '{'] + graph_pattern + ['}', 'LIMIT', limit]
      Query.new(query.join ' ')
    end

  end

  class QuinQueryBuilder < QueryBuilder

    def initialize(schema, mask)
      @schema = schema
      @mask   = mask
    end

    def prefixes
      query = ''
      if [:ordr, :rdr].include? @schema
        query += 'PREFIX wikibase: <http://wikiba.se/ontology-beta#> '
      end
      if [:naryrel, :onaryrel, :ngraphs, :ongraphs].include? @schema
        if @mask[1] == '0' or @mask[3] == '0'
          query += 'PREFIX wikibase: <http://wikiba.se/ontology-beta#> '
        end
      end
      if [:naryrel, :onaryrel, :ngraphs, :ongraphs, :sgprop, :osgprop, :stdreif, :ostdreif, :ordr, :rdr].include? @schema
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
        query += '* ' #rdr-tothink
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
          query += QuinQueryBuilder.new(:naryrel, @mask).graph_pattern(quin)
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
          query += QuinQueryBuilder.new(:ngraphs, @mask).graph_pattern(quin)
        else
          query += "{ GRAPH ?c { #{s[:s]} #{s[:p]} #{s[:o]} } . "
          query += "#{s[:p]} a wikibase:Property . " if @mask[1] == '0'
          query += "FILTER (#{s[:s]} != ?c) " if @mask[0] == '0'
          query += "} OPTIONAL { "
          query += "GRAPH ?c { ?c #{s[:q]} #{s[:qo]} } . "
          query += "#{s[:q]} a wikibase:Property . " if @mask[3] == '0'
          query += "}"
        end
      when :rdr  #BIND( <<?i ?p ?o>> as ?st) .
        query += "BIND  ( <<#{s[:s]} #{s[:p]} #{s[:o]} >> as ?st). ?st wikibase:hasSID ?c. ?c #{s[:q]} #{s[:qo]}  . "
        query += "#{s[:p]} a wikibase:Property . " if @mask[1] == '0'
        query += "#{s[:q]} a wikibase:Property . " if @mask[3] == '0'
        #query += "FILTER (#{s[:s]} != ?c) " if @mask[0] == '0' # we don't need that i think because it should already hold in rdr 
      when :ordr
        if @mask[3] == '1' or @mask[4] == '1'
          query += QuinQueryBuilder.new(:rdr, @mask).graph_pattern(quin)
        else
          query += "{ BIND  ( <<#{s[:s]} #{s[:p]} #{s[:o]} >> as ?st). ?st wikibase:hasSID ?c. "
          query += "#{s[:p]} a wikibase:Property . " if @mask[1] == '0'
          #query += "FILTER (#{s[:s]} != ?c) " if @mask[0] == '0' # we don't need that i think because it should already hold in rdr 
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
          query += QuinQueryBuilder.new(:sgprop, @mask).graph_pattern(quin)
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
          query += QuinQueryBuilder.new(:stdreif, @mask).graph_pattern(quin)
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
        'LIMIT', limit,
        #'#', quin
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
      when :rdr, :ordr
        :rdr
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
          '-Xmx6g',
          '-XX:+UseG1GC',
          '-Djetty.overrideWebXml=override.xml',
          '-Dbigdata.propertyFile=server.properties',
          '-jar',
          'blazegraph.jar')
      end
    end

  end

  class Virtuoso < DBServer

    def initialize(schema, id=1)
      super
      @home = "/usr/local/virtuoso-opensource/var/lib/virtuoso/#{@home}"
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
