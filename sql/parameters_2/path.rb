#!/usr/bin/env ruby

require 'json'
require 'sequel'
require 'set'
require 'singleton'

DB = Sequel.connect('postgres://wikidata:wikidata@localhost/wikidata_enzo')

puts 'Reading five_four_connected_entities'
FIVE_FOUR_STARTS = DB[:five_four_connected_entities].
                   select(:entity_a_id).
                   distinct(:entity_a_id).
                   all.
                   map{ |row| row[:entity_a_id] }
puts "readed #{FIVE_FOUR_STARTS.size} items"

class Path

  attr_reader :path
  
  def node(entity_id)
    claims = DB[:claims].
             where(entity_id: entity_id).
             exclude(valueitem: nil).
             select(:claim_id, :property, :valueitem).all
    {
      entity_id: entity_id,
      claims: claims
    }
  end

  def start_five_four
    FIVE_FOUR_STARTS.sample
  end

  def grow_five_four
    entity_id = @path.last[:entity_id]
    valueitem = DB[:five_four_connected_entities].
                where(entity_a_id: entity_id).
                all.sample[:entity_b_id]
    claim_id = DB[:claims].
               where(entity_id: entity_id, valueitem: valueitem).
               all.sample[:claim_id]
    @path.last[:claim_id] = claim_id
    @path << node(valueitem)
  end

end

class PathFiveFour < Path

  def initialize
    @path = [ node(start_five_four) ]
    grow_five_four
  end
  
end

500.times do
  path = PathFiveFour.new.path
  parameters = path.map do |path_node|
    node = { claims: [] }
    claims   = path_node[:claims]
    if path_node.include? :claim_id
      claim_id = path_node[:claim_id]
      node[:property] = claims.select{ |claim| claim[:claim_id] == claim_id }.first[:property]
      claims.reject!{ |claim| claim[:claim_id] == claim_id }.shuffle!
    end
    rand(3).times do
      claim = claims.pop
      node[:claims] << [claim[:property], claim[:valueitem]]
    end
    rand(3).times do
      claim = claims.pop
      node[:claims] << [claim[:property], rand(2)]
    end
    node
  end
  puts parameters.to_json
end

  
  



