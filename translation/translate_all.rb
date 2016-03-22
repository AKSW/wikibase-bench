#!/usr/bin/env ruby

threads = []
mutex = Mutex.new 

Dir['wikidata-20160104/*.json.gz'].sort.each do |gziped_file_name|
  file_name = gziped_file_name.sub(/.gz$/,'')
  system "gunzip -c #{gziped_file_name} > #{file_name}"
  ['naryrel','ngraphs','sgprop','stdreif'].each do |mode|
    threads << Thread.new do
      mutex.synchronize do
        puts "Processing #{file_name} (#{mode})"
      end
      
      system "./translate.rb #{mode} #{file_name}"
      system "gzip #{file_name.sub(/.json$/,'')}-#{mode}.ttl"
    end
  end

  sleep 1
  mutex.synchronize { puts "Threads: #{threads}" }
  threads.each { |th| th.join }
  threads = []
  system "rm #{file_name}"
end


