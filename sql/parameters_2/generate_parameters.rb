#!/usr/bin/env ruby

require 'json'
require 'sequel'
require 'set'

DB = Sequel.connect('postgres://wikidata:wikidata@localhost/wikidata_enzo')

puts 'Reading start items'

START_ITEMS = DB[:entities_out_degree].
              where('claims >= ?', 5).
              select(:entity_id).
              all.map{ |item| item[:entity_id] }

puts "readed: #{START_ITEMS.size} items."

class Chain

  def initialize
    @chain = [ item_node(START_ITEMS.sample) ]
  end
  
  def grow
    last = @chain.last
    if last[:claims].size > 0
      claim = last[:claims].sample
      last[:next] = claim[:claim_id]
      @chain << item_node(claim[:valueitem])
      return true
    else
      return false
    end
  end

  def item_node(entity_id)
    claims = DB[:claims].
             where(entity_id: entity_id).
             exclude(valueitem: nil).
             select(:claim_id, :property, :valueitem).all
    {
      entity_id: entity_id,
      claims: claims
    }
  end

  def size
    @chain.size
  end
  
end

chain_set = []
chain_set_size = 10
chain_size = 3


while chain_set.size < chain_set_size
  chain = Chain.new
  while chain.size < chain_size
    break unless chain.grow
  end
  if chain.size == chain_size
    chain_set << chain
    print '+'
  else
    print '.'
  end
end

puts ''

  
  



