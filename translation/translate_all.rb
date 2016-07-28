#!/usr/bin/env ruby

threads = []
mutex = Mutex.new

if ARGV.size != 1
  puts 'usage: translate_all.rb <directory>'
  exit 1
end

Dir["#{ARGV[0]}/*.json.gz"].sort.each do |gziped_file_name|
  file_name = gziped_file_name.sub(/.gz$/,'')
  system "gunzip -c #{gziped_file_name} > #{file_name}"
  ['naryrel','ngraphs','sgprop','stdreif','rdr'].each do |mode|
    threads << Thread.new do
      mutex.synchronize do
        puts "Processing #{file_name} (#{mode})"
      end

      system "./translate.rb #{mode} #{file_name}"
      system "gzip #{file_name.sub(/.json$/,'')}-#{mode}.nq"
    end
  end

  sleep 1
  mutex.synchronize { puts "Threads: #{threads}" }
  threads.each { |th| th.join }
  threads = []
  system "rm #{file_name}"
end
