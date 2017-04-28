# This file provides a configuration for blazegraph:

CONFIG = {
  engine: Wikidata::Blazegraph,
  dbfiles: 'sdw',
  #schemas: [:data, :cpprop, :ngraphs, :rdr, :sgprop, :naryrel, :stdreif],
  schemas: [:naryrel],
  #templates: ['DBM-HAR-01','DBQ-HAR-01'],
  templates: ['DBQ-HAR-01'],
  folder: '/home/benchmark/data2/wikidata/wikibase-bench/queries/sdw/',
  homes: [1],
  queries: (0...40).to_a,
  max_solutions: 10000,
  client_timeout: 400,
  server_timeout: 240
}
