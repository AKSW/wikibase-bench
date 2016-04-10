module Wikidata

  module BlazeGraph
    def self.dbdir(schema, id=1)
      case schema
      when :naryrel, :onaryrel
        "db-naryrel-#{id}"
      when :ngraphs, :ongraphs
        "db-ngraphs-#{id}"
      when :sgprop, :osgprop
        "db-sgprop-#{id}"
      when :stdreif, :ostdreif
        "db-stdreif-#{id}"
      end
    end

    def self.properties(schema)
      case schema
      when :ngraphs, :ongraphs
        "quads.properties"
      else
        "triples.properties"
      end
    end

    def self.start(schema, id=1)
      fork do
        Dir.chdir dbdir(schema, id)
        $stdout.reopen("out.log", "w")
        $stderr.reopen("err.log", "w")
        exec(['java', 'blazegraph'],
          "-Dbigdata.propertyFile=../#{properties(schema)}",
          "-jar", "blazegraph.jar",
        )
      end
    end

    def self.stop()
      system 'pidof blazegraph | xargs kill'
    end

  end
end

def load_data(schema, directory)
  database = "db-#{schema}-1"
  wikidata = File.absolute_path(directory)
  if File.exists? database
    raise "Database #{database} exists"
  else
    system "mkdir #{database}"
    Dir.chdir database
    system "ln -s ../#{properties(schema)} server.properties"
    system "ln -s ../blazegraph.jar blazegraph.jar"
    system "ln -s #{wikidata} wikidata"
  end
  t1 = Time.now
  system "java -cp blazegraph.jar com.bigdata.rdf.store.DataLoader server.properties wikidata"
  t2 = Time.now
  Dir.chdir '..'
  t2-t1
end

log = File.new('loading.log', 'a')
[:naryrel, :ngraphs, :sgprop, :stdreif].each do |schema|
  dir = File.join(File.dirname(File.dirname(Dir.pwd)),'wikidata',"nq-#{schema}")
  log.puts "Loading #{schema} from #{dir}"
  time = load_data(schema, dir)
  log.puts "Elapsed time: #{time}"
end
