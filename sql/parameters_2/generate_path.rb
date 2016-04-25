#!/usr/bin/env ruby

require 'json'
require 'sequel'

if ARGV.size != 2
  puts "Usage: ./generate_paths.rb <length> <number>"
  exit 1
end

PATH_LENGTH = ARGV[0]
PATH_NUMBER = ARGV[1]

DB = Sequel.connect('postgres://wikidata:wikidata@localhost/wikidata_enzo')

paths = DB[:paths].
  where(size: PATH_LENGTH).
  order(Sequel.lit('RANDOM()')).
  limit(PATH_NUMBER)

paths.each do |path|
  p path
end
