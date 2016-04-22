# This file provides a configuration for blazegraph:

CONFIG = {
  engine: Wikidata::Virtuoso,
  schemas: [:onaryrel],
  masks: ['10000'],
  quins: lambda { |mask| "query_parameters/quins/quins_#{mask}.csv" },
  homes: [1],
  max_queries: 3,
  max_solutions: 10000,
  client_timeout: 60,
  server_timeout: 60
}
