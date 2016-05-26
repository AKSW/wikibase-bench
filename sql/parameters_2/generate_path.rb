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

STDOUT.sync = true

paths = DB[:paths].
  where(size: PATH_LENGTH).
  order(Sequel.lit('RANDOM()')).
  limit(PATH_NUMBER)

paths.each do |row|
  nodes = row[:nodes][1...-1].split(',').reverse
  path = []
  while nodes.size > 0
    node_id = nodes.pop
    node = {entity_id: node_id, claims: []}
    claims = DB[:claims].where(entity_id: node_id).exclude(valueitem: nil).select(:claim_id, :property, :valueitem).all
    if nodes.size > 0
      valueitem = nodes.last
      claim = DB[:claims].where(entity_id: node_id, valueitem: valueitem).select(:claim_id, :property).all.sample
      node[:property] = claim[:property]
      claims.reject!{|c| c[:claim_id] == claim[:claim_id]}.shuffle
    end
    m = n = 0
    while m + n == 0
      m = rand(3)
      n = rand(3)
    end
    properties = []
    while n+n > 0 and claims.size > 0 do
      claim = claims.pop
      unless properties.include?(claim[:property])
        properties << claim[:property]
        if rand(2) == 0
          if m > 0
            m -= 1
            node[:claims] << [claim[:property], claim[:valueitem]]
          end
        else
          if n > 0
            n -= 1
            node[:claims] << [claim[:property], rand(2)]
          end
        end
      end
    end
    path << node if n+n == 0
  end
  puts path.to_json if path.size == PATH_LENGTH
end
