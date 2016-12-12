#!/usr/bin/env ruby

MODE = ARGV[0]
LOG  = File.new("loading.log", 'w')

def virtuoso_run(script, mode)
  puts "Running #{script} (#{mode})"
  LOG.puts "Running #{script} (#{mode})"
  LOG.flush
  stime = Time.now
  system "isql-v 1111 dba dba VERBOSE=OFF #{script}"
  etime = Time.now - stime
  LOG.puts "Elapsed time: #{etime} seconds"
  LOG.flush
end

['metadata'].each do |mode|#['cpprop','data','naryrel','ngraphs','sgprop','stdreif'].each do |mode|
  puts "Starting server (#{mode})"
  system "cd /home/benchmark/data2/wikidata/wikibase-bench/dbfiles/virtuoso/sdw/db-#{mode}-1 && virtuoso-t"
  sleep 60

  virtuoso_run("disable_auto_indexing.sql", mode)
  virtuoso_run("setup_list_#{mode}_sdw.sql", mode)
  virtuoso_run("load_data.sql", mode)
  virtuoso_run("enable_auto_indexing.sql", mode)

  puts "Stoping server (#{mode})"
  system "pidof virtuoso-t | xargs kill"
  sleep 60
end
