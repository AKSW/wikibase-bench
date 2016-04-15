def properties(schema)
  if [:ngraphs, :ongraphs].include? schema
    "quads.properties"
  else
    "triples.properties"
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
  system "java -Xmx6g -cp blazegraph.jar com.bigdata.rdf.store.DataLoader -namedGraph http://wikidata.org server.properties wikidata"
  t2 = Time.now
  Dir.chdir '..'
  t2-t1
end

log = File.new('loading.log', 'a')

if ARGV.size > 0
  schemas = [ARGV[0].to_sym]
else
  schemas = [:naryrel, :ngraphs, :sgprop, :stdreif]
end

schemas.each do |schema|
  dir = File.join(File.dirname(File.dirname(Dir.pwd)),'wikidata',"nq-#{schema}")
  log.puts "Loading #{schema} from #{dir}"
  log.flush
  time = load_data(schema, dir)
  log.puts "Elapsed time: #{time}"
  log.flush
end
