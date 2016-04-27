# This file provides a configuration for blazegraph:

CONFIG = {
  engine: Wikidata::Virtuoso,
  schemas: [:naryrel, :ngraphs, :sgprop, :stdreif],
  path_files: (1..3).map { |i| "query_parameters/paths/path_#{i}.json" },
  homes: [1,2],
  queries: (0...300).to_a,
  max_solutions: 10000,
  client_timeout: 60,
  server_timeout: 60
}
