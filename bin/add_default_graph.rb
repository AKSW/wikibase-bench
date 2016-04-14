#!/usr/bin/env ruby

require 'rdf'
require 'rdf/nquads'

if ARGV.size == 1
  directory = ARGV[0]
else
  puts "Usage: add_default_graph.rb <directory>"
  exit 1
end

Dir[File.join(directory,'*.nq.gz')].each do |file_name|
  puts "Fixing #{file_name}"
  system "gunzip #{file_name}"
  out = File.new(file_name.sub(/.gz$/,'.fixed'),'w')
  RDF::NQuads::Reader.open(file_name.sub(/.gz$/,'')) do |reader|
    reader.each_statement do |statement|
      unless statement.has_graph?
        statement.graph_name = RDF::URI.new('http://wikidata.org')
      end
      out.puts statement.to_s
    end
  end
  out.close
end
