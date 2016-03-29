#!/usr/bin/env ruby

def query(mode, pattern, quin, limit)
  case mode
  when :naryrel
    case pattern
    when '00001'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?p ?o ?qp
      WHERE {
        ?s ?p _:st .
        _:st ?pv ?o ; ?qp wd:#{quin[4]} .
        ?p wikibase:propertyValue ?pv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '00010'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?p ?o ?qv
      WHERE {
        ?s ?p _:st .
        _:st ?pv ?o ; p:#{quin[3]} ?qv .
        ?p wikibase:propertyValue ?pv .
      }
      LIMIT #{limit}
      """
    when '00011'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?p ?o
      WHERE {
        ?s ?p _:st .
        _:st ?pv ?o ; p:#{quin[3]} wd:#{quin[4]} .
        ?p wikibase:propertyValue ?pv .
      }
      LIMIT #{limit}
      """
    when '00100'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?p ?qp ?qv
      WHERE {
        ?s ?p _:st .
        _:st ?pv wd:#{quin[2]} ; ?qp ?qv .
        ?p wikibase:propertyValue ?pv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '00101'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?p ?qp
      WHERE {
        ?s ?p _:st .
        _:st ?pv wd:#{quin[2]} ; ?qp wd:#{quin[4]} .
        ?p wikibase:propertyValue ?pv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '00110'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?p
      WHERE {
        ?s ?p _:st .
        _:st ?pv wd:#{quin[2]} ; p:#{quin[3]} ?qv .
        ?p wikibase:propertyValue ?pv .
      }
      LIMIT #{limit}
      """
    when '00111'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?p
      WHERE {
        ?s ?p _:st .
        _:st ?pv wd:#{quin[2]} ; p:#{quin[3]} wd:#{quin[4]} .
        ?p wikibase:propertyValue ?pv .
      }
      LIMIT #{limit}
      """
    when '01000'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      SELECT ?s ?o ?qp ?qv
      WHERE {
        ?s p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; ?qp ?qv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '01001'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?o ?qp
      WHERE {
        ?s p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; ?qp wd:#{quin[4]} .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '01010'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      SELECT ?s ?o ?qv
      WHERE {
        ?s p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; p:#{quin[3]} ?qv .
      }
      LIMIT #{limit}
      """
    when '01011'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?o
      WHERE {
        ?s p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; p:#{quin[3]} wd:#{quin[4]} .
      }
      LIMIT #{limit}
      """
    when '01100'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?qp ?pv
      WHERE {
        ?s p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} wd:#{quin[2]} ; ?qp ?qv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '01101'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?qp ?pv
      WHERE {
        ?s p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} wd:#{quin[2]} ; ?qp wd:#{quin[4]} .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '01110'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?qp ?pv
      WHERE {
        ?s p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} wd:#{quin[2]} ; p:#{quin[3]} ?qv .
      }
      LIMIT #{limit}
      """
    when '01111'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s
      WHERE {
        ?s p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} wd:#{quin[2]} ; p:#{quin[3]} wd:#{quin[4]} .
      }
      LIMIT #{limit}
      """
    when '10000'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?p ?o ?qp ?qv
      WHERE {
        wd:#{quin[0]} ?p _:st .
        _:st ?pv ?o ; ?qp ?qv .
        ?p wikibase:propertyValue ?pv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '10001'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?p ?o ?qp
      WHERE {
        wd:#{quin[0]} ?p _:st .
        _:st ?pv ?o ; ?qp wd:#{quin[4]} .
        ?p wikibase:propertyValue ?pv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '10010'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?p ?o ?qp
      WHERE {
        wd:#{quin[0]} ?p _:st .
        _:st ?pv ?o ; p:#{quin[3]} ?qv .
        ?p wikibase:propertyValue ?pv .
      }
      LIMIT #{limit}
      """
    when '10011'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?p ?o
      WHERE {
        wd:#{quin[0]} ?p _:st .
        _:st ?pv ?o ; p:#{quin[3]} wd:#{quin[4]} .
        ?p wikibase:propertyValue ?pv .
      }
      LIMIT #{limit}
      """
    when '10100'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?p ?qp ?qv
      WHERE {
        wd:#{quin[0]} ?p _:st .
        _:st ?pv wd:#{quin[2]} ; ?qp ?qv .
        ?p wikibase:propertyValue ?pv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '10101'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?p ?qp
      WHERE {
        wd:#{quin[0]} ?p _:st .
        _:st ?pv wd:#{quin[2]} ; ?qp wd:#{quin[4]} .
        ?p wikibase:propertyValue ?pv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '10110'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?p ?qv
      WHERE {
        wd:#{quin[0]} ?p _:st .
        _:st ?pv wd:#{quin[2]} ; p:#{quin[3]} ?qv .
        ?p wikibase:propertyValue ?pv .
      }
      LIMIT #{limit}
      """
    when '10111'
      """
      PREFIX wikibase: <http://wikiba.se/ontology-beta#>
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?p
      WHERE {
        ?s ?p _:st .
        _:st ?pv wd:#{quin[2]} ; p:#{quin[3]} wd:#{quin[4]} .
        ?p wikibase:propertyValue ?pv .
      }
      LIMIT #{limit}
      """
    when '11000'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?o ?qp ?qv
      WHERE {
        wd:#{quin[0]} p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; ?qp ?qv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '11001'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?o ?qp
      WHERE {
        wd:#{quin[0]} ps:#{quin[1]} _:st .
        _:st psv:#{quin[1]} ?o ; ?qp wd:#{quin[4]} .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '11010'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?o ?qv
      WHERE {
        wd:#{quin[0]} p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; p:#{quin[3]} ?qv .
      }
      LIMIT #{limit}
      """
    when '11011'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?o
      WHERE {
        wd:#{quin[0]} p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; p:#{quin[3]} wd:#{quin[4]} .
      }
      LIMIT #{limit}
      """
    when '11100'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?qp ?qv
      WHERE {
        wd:#{quin[0]} p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; ?qp ?qv .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '11101'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?qp
      WHERE {
        wd:#{quin[0]} p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; ?qp wd:#{quin[4]} .
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '11110'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?qv
      WHERE {
        wd:#{quin[0]} p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} ?o ; p:#{quin[3]} ?qv .
      }
      LIMIT #{limit}
      """
    when '11111'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      PREFIX ps: <http://www.wikidata.org/prop/statement/>
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT *
      WHERE {
        wd:#{quin[0]} p:#{quin[1]} _:st .
        _:st ps:#{quin[1]} wd:#{quin[2]} ; p:#{quin[3]} wd:#{quin[4]} .
      }
      """
    end
  when :ngraphs
    case pattern
    when '00001'
      """
      PREFIX wd: <http://www.wikidata.org/entity/>
      SELECT ?s ?p ?o ?qp
      WHERE {
        GRAPH _:st {
          ?s ?p ?o .
          _:st ?qp wd:#{quin[4]} .
          ?qp a wikibase:Property .
        }
      }
      LIMIT #{limit}
      """
    when '00010'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?p ?o ?qv
      WHERE {
        GRAPH _:st {
          ?s ?p ?o .
          _:st p:#{quin[3]} ?qv .
        }
      }
      LIMIT #{limit}
      """
    when '00011'
      """
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?p ?o
      WHERE {
        GRAPH _:st {
          ?s ?p ?o .
          _:st :#{quin[3]} wd:#{quin[4]} .
        }
      }
      LIMIT #{limit}
      """
    when '00100'
      """
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      SELECT ?s ?p ?qp ?qv
      WHERE {
        GRAPH _:st {
          ?s ?p wd:#{quin[2]} .
          _:st ?qp ?qv .
          ?qp a wikibase:Property .
        }
      }
      LIMIT #{limit}
      """
    when '00101'
      """
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      SELECT ?s ?p ?qp
      WHERE {
        GRAPH _:st {
          ?s ?p wd:#{quin[2]} .
          _:st ?qp wd:#{quin[4]} .
          ?qp a wikibase:Property .
        }
      }
      LIMIT #{limit}
      """
    when '00111'
      """
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?p
      WHERE {
        GRAPH _:st {
          ?s ?p wd:#{quin[2]} .
          _:st p:#{quin[3]} wd:#{quin[4]} .
        }
      }
      LIMIT #{limit}
      """
    when '01000'
      """
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?o ?qp ?qv
      WHERE {
        GRAPH _:st {
          ?s p:#{quin[1]} ?o .
          _:st ?qp ?qv .
        }
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '01001'
      """
      PREFIX wd: <http://www.wikidata.org/entity/>
      PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?o ?qp
      WHERE {
        GRAPH _:st {
          ?s p:#{quin[1]} ?o .
          _:st ?qp wd:#{quin[4]} .
        }
        ?qp a wikibase:Property .
      }
      LIMIT #{limit}
      """
    when '01010'
      """
      PREFIX p: <http://www.wikidata.org/prop/>
      SELECT ?s ?o ?qv
      WHERE {
        GRAPH _:st {
          ?s p:#{quin[1]} ?o .
          _:st p:#{quin[3]} ?qv .
        }
      }
      LIMIT #{limit}
      """
    end
  end
end

def pretify(query_string)
  query_string.gsub(/\n      /,"\n").strip
end

mode = :naryrel
(1..31).map{ |x| "%05b" % x }.each do |pattern|
  puts "Genering queries for #{pattern} (#{mode})"
  dir = File.join('queries',"quins-#{mode}-#{pattern}")
  system "mkdir #{dir}" unless File.exists? dir
  i = 1
  File.open("data/quin-patterns-#{pattern}.csv", 'r').each do |line|
    out = File.open(File.join(dir,"query-%03i.sparql" % i), 'w')
    out.puts pretify(query(:naryrel, pattern, line.split, 10000))
    out.close
    i += 1
  end
end
