#!/usr/bin/env ruby

MODE = ARGV[0]
LOG  = File.new("loading-#{MODE}.log", 'w')

def virtuoso_run(script)
  puts "Running #{script}"
  LOG.puts "Running #{script}"
  stime = Time.now
  system "isql 1111 dba dba VERBOSE=OFF 'EXEC=status()' #{script}"
  etime = Time.now - time
  LOG.puts "Ellapsed time: #{etime} seconds"
end

# Running scripts to load the data.

virtuoso_run("disable_auto_indexing.sql")
virtuoso_run("setup_list_#{MODE}.sql")
virtuoso_run("load_data.sql")
virtuoso_run("see_errors.sql")
virtuoso_run("enable_auto_indexing.sql")

