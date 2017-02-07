def properties(schema)
  if [:ngraphs, :ongraphs].include? schema
    "quads.properties"
  elsif [:rdr, :ordr].include? schema
     "rdr.properties"
  else
    "triples.properties"
  end
end

def fileformat(schema)
  if [:ngraphs, :ongraphs].include? schema
    "NQUADS"
  elsif [:rdr, :ordr].include? schema
    "NTRIPLES_RDR"
  else
    "NQUADS"
  end
end

def load_data(schema, directory)
  database = "db-#{schema}-1"
  wikidata = File.absolute_path(directory)
#  if File.exists? database
#    raise "Database #{database} exists"
#  else
#    system "mkdir #{database}"
    Dir.chdir database
#    system "ln -s ../#{properties(schema)} server.properties"
#    system "ln -s ../blazegraph.jar blazegraph.jar"
#    system "ln -s #{wikidata} wikidata"
#  end
  t1 = Time.now
  iotop = "iotop -a -o -b -t -d 60 > iotop-#{schema}-data-increment.log &"
  system iotop
  comd =  "java -Xmx16g -cp blazegraph.jar com.bigdata.rdf.store.DataLoader -format #{fileformat(schema)} -defaultGraph http://wikidata.org server.properties wikidata"
  puts comd
  system comd
  t2 = Time.now
  system "pkill iotop"
  Dir.chdir '..'
  t2-t1
end

log = File.new('loading.log', 'a')

if ARGV.size > 0
  schemas = [ARGV[0].to_sym]
else
  schemas = [:cpprop, :data, :naryrel, :stdreif, :sgprop]
end

schemas.each do |schema|
  dir = File.join(File.dirname(File.dirname(Dir.pwd)),'wikidata',"nq-#{schema}")
  log.puts "Loading #{schema} from #{dir}"
  log.flush
  time = load_data(schema, dir)
  log.puts "Elapsed time: #{time}"
  log.flush
end
