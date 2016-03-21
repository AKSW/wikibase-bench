#!/usr/bin/env ruby

# A quin is is a secuence of (c0,...,c4) where ci is a constant for each
# suffix i. A pattern is a sequence that have both, variables and constants.
# We denote variables as ?x0,...,?x4.
#
# A quin pattern P matches a quin Q if there is an assignment h of constants
# variables such that h(P) = Q.
#
# This script generate almost 500 unrepeated patterns for each mask
# from 00001 to 11111, where 1 a 0 means a constant or a variable in a
# position of a quin. For example, given the quin (c0,...,c4) and
# the mask 01011, then it generates the pattern (?x0,c1,?x2,c3,c4). 
#
# This script reads quins in order from the file 'data/quins-all.csv'
# and generate a pattern for each of them to complete 500. Also, it
# ensure that patterns are not repeated. Note that different quins may
# be matched by the same pattern.

require 'set'

all = []

puts "Reading quins"
File.open('data/quins-all.csv', 'r').each do |line|
  all << line.split(' ').map{ |x| x.strip }
end

puts "readed #{all.size} quins"

(1..31).each do |quin_pattern|
  puts "Shuffling quins"
  all.sort.shuffle(random: Random.new(quin_pattern))

  quin_mask = "%05b" % quin_pattern
  set  = Set.new
  k = 0

  puts "Generating quins for #{quin_mask}"
  while ((set.size < 500) and (k < all.size))
    quin = all[k].clone
    (0..4).each do |i|
      quin[i] = "?x#{i}" if quin_mask[i] == '0'
    end

    unless set.include? quin
      set << quin
    end

    k += 1
  end

  ofile = File.open("data/quin-patterns-#{quin_mask}.csv", 'w')
  set.to_a.sort.shuffle(random: Random.new(1)).each do |q|
    ofile.puts q.join(' ')
  end
  ofile.close
end
