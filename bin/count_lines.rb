#!/usr/bin/env ruby

unless ARGV.size == 1
  puts 'usage: count_lines.rb <directory>'
  exit 1
end

lines = 0

Dir["#{ARGV[0]}/*.gz"].sort.each do |file_name|
  puts "Counting in #{file_name}"
  n = `gunzip -c #{file_name} | wc -l`
  puts "#{n} lines"
end

puts "Total: #{lines} lines"
