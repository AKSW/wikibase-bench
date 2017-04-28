def index(schema)
  if [:ngraphs, :ongraphs, :fongraphs].include? schema
    ""
  else
    "--index-triples-only" # do not create graph index for ntriples
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
  if File.exists? database
    raise "Database #{database} exists"
  else
    system "mkdir #{database}"
    Dir.chdir database
    #system "ln -s ../#{properties(schema)} server.properties"
    system "cp -R ../../stardog_home/bin bin"
    system "cp -R ../../stardog_home/client client"
    system "cp -R ../../stardog_home/server server"
    system "cp -R ../../stardog_home/docs docs"
    system "cp -R ../../stardog_home/webconsole webconsole"
    system "cp ../../stardog_home/stardog-license-key.bin stardog-license-key.bin"
    system "ln -s  /home/benchmark/data2/wikidata/wikibase-bench/wikidata/sdw/#{schema} data-to-load"
  end
  system "bin/stardog-admin server stop"
  t1 = Time.now
  iotop = "iotop -a -o -b -t -d 60 > iotop_stardog_#{schema}.log &"
  system iotop
  start = "bin/stardog-admin server start --disable-security"
  system({"STARDOG_JAVA_ARGS" => "-Xmx6G -Xms6G -XX:MaxDirectMemorySize=10G"},start)
  comd =  "bin/stardog-admin db create -n kb #{index(schema)} -o reasoning.type=NONE query.all.graphs=true strict.parsing=false -- data-to-load"
  puts comd
  system comd
  t2 = Time.now
  system "bin/stardog-admin server stop"
  system "pkill iotop"
  Dir.chdir '..'
  t2-t1
end

def load_data_increment(schema, directory)
  database = "db-#{schema}-1"
  wikidata = File.absolute_path(directory)
  if File.exists? database
    raise "Database #{database} exists"
  else
    #system "mkdir #{database}"
    system "cp -R db-metadata-1 #{database}"
    Dir.chdir database
    #system "ln -s ../#{properties(schema)} server.properties"
    system "rm data-to-load"
    system "ln -s  /home/benchmark/data2/wikidata/wikibase-bench/wikidata/sdw/#{schema} data-to-load"
  end
  system "bin/stardog-admin server stop"
  t1 = Time.now
  iotop = "iotop -a -o -b -t -d 60 > iotop_stardog_#{schema}.log &"
  system iotop
  start = "bin/stardog-admin server start --disable-security"
  system({"STARDOG_JAVA_ARGS" => "-Xmx6G -Xms6G -XX:MaxDirectMemorySize=10G"},start)
  comd =  "bin/stardog data add kb data-to-load"
  puts comd
  system comd
  t2 = Time.now
  system "bin/stardog-admin server stop"
  system "pkill iotop"
  Dir.chdir '..'
  t2-t1
end


log = File.new('loading.log', 'a')

if ARGV.size > 0
  schemas = [ARGV[0].to_sym]
else
  schemas = [:metadata, :naryrel, :cpprop, :sgprop, :stdreif, :data, :ngraphs]
end

schemas.each do |schema|
  dir = File.join(File.dirname(File.dirname(Dir.pwd)),'sdw',"db-#{schema}-1")
  log.puts "Loading stardog #{schema} from #{dir}"
  log.flush
  if [:metadata,:ngraphs,:inctest].include? schema
    time = load_data(schema, dir)
  else
    time = load_data_increment(schema, dir)
  end
  log.puts "Elapsed time: #{time}"
  log.flush
end
