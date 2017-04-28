# This file provides a configuration for stardog:

CONFIG = {
  engine: Wikidata::Stardog,
  dbfiles: 'sdw',
  #schemas: [:data, :cpprop, :ngraphs, :sgprop, :naryrel, :stdreif],
  schemas: [:sgprop],
  templates: ['DBM-HAR-02','DBQ-HAR-02'],
  folder: '/home/benchmark/data2/wikidata/wikibase-bench/queries/sdw/',
  homes: [1],
  queries: (0...40).to_a,
  max_solutions: 10000,
  client_timeout: 400,
  server_timeout: 240
}
