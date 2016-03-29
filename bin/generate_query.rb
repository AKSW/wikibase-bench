#!/usr/bin/env ruby


def generate_query_naryrel(mask, quin, limit)
  query = ''

  # Prefixes
  if mask[1] == '0' or mask[3] == '0'
    query += 'PREFIX wikibase: <http://wikiba.se/ontology-beta#> '
  end
  if mask[0] == '1' or mask[2] == '1' or mask[4] == '1'
    query += 'PREFIX wd: <http://www.wikidata.org/entity/> '
  end
  if mask[1] == '1' or mask[3] == '1'
    query += 'PREFIX p: <http://www.wikidata.org/prop/> '
  end
  if mask[1] == '1'
    query += 'PREFIX ps: <http://www.wikidata.org/prop/statement/> '
  end
  
  # Select clause
  query += 'SELECT '
  if mask == '11111'
    query += '* '
  else
    query += '?s '  if mask[0] == '0'
    query += '?p '  if mask[1] == '0'
    query += '?o '  if mask[2] == '0'
    query += '?q '  if mask[3] == '0'
    query += '?qo ' if mask[4] == '0'
  end
  query += '{ '

  # Pattern variables
  s  = ((mask[0] == '0') ? '?s'  : "wd:#{quin[0]}")
  p  = ((mask[1] == '0') ? '?p'  : "p:#{quin[1]}")
  ps = ((mask[1] == '0') ? '?ps' : "ps:#{quin[1]}")
  o  = ((mask[2] == '0') ? '?o'  : "wd:#{quin[2]}")
  q  = ((mask[3] == '0') ? '?q'  : "p:#{quin[3]}")
  qo = ((mask[4] == '0') ? '?qo' : "wd:#{quin[4]}")
  query += "#{s} #{p} [ #{ps} #{o} ; #{q} #{qo} ] . "

  # Aditional restrictions
  query += "#{p} wikibase:propertyValue #{ps} . " if mask[1] == '0'
  query += "#{q} a wikibase:Property . " if mask[3] == '0'

  # Limit
  query += "} LIMIT #{limit}"
end

def query(mode, mask, quin, limit)
  case mode
  when :naryrel
    generate_query_naryrel(mask, quin, limit)
  end
end

mode = :naryrel
(1..31).map{ |x| "%05b" % x }.each do |pattern|
  puts "Genering queries for #{pattern} (#{mode})"
  dir = File.join('queries',"quins-#{mode}-#{pattern}")
  system "mkdir #{dir}" unless File.exists? dir
  i = 1
  File.open("data/quin-patterns-#{pattern}.csv", 'r').each do |line|
    out = File.open(File.join(dir,"query-%03i.sparql" % i), 'w')
    out.puts query(:naryrel, pattern, line.split, 10000)
    out.close
    i += 1
  end
end
