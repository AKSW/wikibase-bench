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
#  where(size: PATH_LENGTH).
  order(Sequel.lit('RANDOM()')).
  limit(PATH_NUMBER)

paths.each do |row|
  nodes = row[:nodes][1...-1].split(',').reverse
  path = []
  while nodes.size > 0
    node = {claims: []}
    node_id = nodes.pop
    claims = DB[:claims].where(entity_id: node_id).exclude(valueitem: nil).select(:claim_id, :property, :valueitem).all
    if nodes.size > 0
      valueitem = nodes.last
      claim = DB[:claims].where(entity_id: node_id, valueitem: valueitem).select(:claim_id, :property).all.sample
      node[:property] = claim[:property]
      claims.reject!{|c| c[:claim_id] == claim[:claim_id]}.shuffle
    end
    rand(3).times do
      claim = claims.pop
      node[:claims] << [claim[:property], claim[:valueitem]]
    end
    rand(3).times do
      claim = claims.pop
      node[:claims] << [claim[:property], rand(2)]
    end
    path << node
  end
  puts path.to_json
end
