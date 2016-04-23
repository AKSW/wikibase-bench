#!/usr/bin/env ruby

require 'csv'

entities = {}

CSV.parse(File.new('data/entity_claims.csv','r')).map do |row|
  entities[row[0]] = [] unless entities.include? row[0]
  entities[row[0]] << [row[1], row[2]]
end

entities.keys.shuffle.each do |entity|
  n = m = 0
  while n + m == 0
    n = rand 4
    m = rand 4
  end
  claims = entities[entity].shuffle
  list = []
  n.times { list << claims.pop }
  m.times { list << [claims.pop[0], rand(2)] }
  puts list.map{ |x| x.join(':') }.join(' ')
end
