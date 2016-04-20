
CONFIG = {
  quins_directory: 'data',
}

CONFIG[:quins_directory] = 'data'
CONFIG[:max_solutions] = 10000
CONFIG[:max_queries] = 500
CONFIG[:engine] = Wikidata::BlazeGraph
CONFIG[:schema] = :onaryrel
