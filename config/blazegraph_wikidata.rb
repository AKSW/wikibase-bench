# This file provides a configuration for blazegraph:

CONFIG = {
  engine: Wikidata::Blazegraph,
  dbfiles: 'wikidata',
  #schemas: [:onaryrel, :fongraphs, :osgprop, :ostdreif, :fordr, :ordr],
  schemas: [:ordr],
  #masks: (1..31).map { |i| "%05b" % i },
  masks: (1..7).map { |i| "%05b" % i },
  quins: lambda { |mask| "query_parameters/quins/quins_#{mask}.csv" },
  homes: [1],
  queries: (0...300).to_a,
  max_solutions: 10000,
  client_timeout: 120,
  server_timeout: 60
}
