require 'set'
require 'json'
require 'rdf'
require 'rdf/ntriples'
include RDF

class Translator

  def initialize(mode, file)
    @mode = mode
    @file = file

    # Prefixes
    @rdf      = RDF::Vocabulary.new("http://www.w3.org/1999/02/22-rdf-syntax-ns#")
    @xsd      = RDF::Vocabulary.new("http://www.w3.org/2001/XMLSchema#")
    @rdfs     = RDF::Vocabulary.new("http://www.w3.org/2000/01/rdf-schema#")
    @owl      = RDF::Vocabulary.new("http://www.w3.org/2002/07/owl#")
    @wikibase = RDF::Vocabulary.new("http://wikiba.se/ontology-beta#")
    @wdata    = RDF::Vocabulary.new("https://www.wikidata.org/wiki/Special:EntityData/")
    @wd       = RDF::Vocabulary.new("http://www.wikidata.org/entity/")
    @wds      = RDF::Vocabulary.new("http://www.wikidata.org/entity/statement/")
    @wdref    = RDF::Vocabulary.new("http://www.wikidata.org/reference/")
    @wdv      = RDF::Vocabulary.new("http://www.wikidata.org/value/")
    @wdt      = RDF::Vocabulary.new("http://www.wikidata.org/prop/direct/")
    @p        = RDF::Vocabulary.new("http://www.wikidata.org/prop/")
    @ps       = RDF::Vocabulary.new("http://www.wikidata.org/prop/statement/")
    @psv      = RDF::Vocabulary.new("http://www.wikidata.org/prop/statement/value/")
    @pq       = RDF::Vocabulary.new("http://www.wikidata.org/prop/qualifier/")
    @pqv      = RDF::Vocabulary.new("http://www.wikidata.org/prop/qualifier/value/")
    @pr       = RDF::Vocabulary.new("http://www.wikidata.org/prop/reference/")
    @prv      = RDF::Vocabulary.new("http://www.wikidata.org/prop/reference/value/")
    @wdno     = RDF::Vocabulary.new("http://www.wikidata.org/prop/novalue/")
    @skos     = RDF::Vocabulary.new("http://www.w3.org/2004/02/skos/core#")
    @schema   = RDF::Vocabulary.new("http://schema.org/")
    @cc       = RDF::Vocabulary.new("http://creativecommons.org/ns#")
    @geo      = RDF::Vocabulary.new("http://www.opengis.net/ont/geosparql#")
    @prov     = RDF::Vocabulary.new("http://www.w3.org/ns/prov#")
    @commons  = RDF::Vocabulary.new("http://commons.wikimedia.org/wiki/Special:FilePath/")

    @writer = RDF::NTriples::Writer.new

    # To remove the entities that are referred in claims, but have no Wikidata page.
    @entities_without_page = Set.new([
                                       "Q19646575",
                                       "Q2689461",
                                       "Q4501188",
                                       "Q12455619",
                                       "Q18017532",
                                       "Q18017714",
                                       "Q20901643",
                                       "Q16870965",
                                       "Q21791504",
                                       "Q16539709",
                                       "Q3621971",
                                       "Q18057760",
                                       "Q1812384",
                                       "Q2283711",
                                       "Q17023559",
                                       "Q12413469",
                                       "Q18791888",
                                       "Q878873",
                                       "Q18820049",
                                       "Q13432010",
                                       "Q16020852",
                                       "Q5568256",
                                       "Q18845462",
                                       "Q461482",
                                       "Q18845463",
                                       "Q2857223",
                                       "Q18845464",
                                       "Q8479771",
                                       "Q18845458",
                                       "Q18845467",
                                       "Q18845455",
                                       "Q18583918",
                                       "Q18790034",
                                       "Q18845469",
                                       "Q4662641",
                                       "Q3665783",
                                       "Q13845711",
                                       "Q16402906",
                                       "Q18384871",
                                       "Q11603994",
                                       "Q20828278",
                                       "Q20828279",
                                       "Q3952961",
                                       "Q16800831",
                                       "Q18845475",
                                       "Q8106179",
                                       "Q6289940",
                                       "Q4733328",
                                       "Q17112087",
                                       "Q6232820",
                                       "Q5580601",
                                       "Q2171012",
                                       "Q20128378",
                                       "Q6126648",
                                       "Q7500591",
                                       "Q4896660",
                                       "Q7839192",
                                       "Q5066448",
                                       "Q19819704",
                                       "Q10843103",
                                       "Q3954990",
                                       "Q21901383",
                                       "Q10846361",
                                       "Q5950433",
                                       "Q15149993",
                                       "Q14895380",
                                       "Q19630862",
                                       "Q2371997",
                                       "Q6373369",
                                       "Q16531403",
                                       "Q6934126",
                                       "Q17986504",
                                       "Q18670093",
                                       "Q20087567",
                                       "Q18845471",
                                       "Q18845473",
                                       "Q18845476",
                                       "Q18845479",
                                       "Q18845457",
                                       "Q889487",
                                       "Q18911956",
                                       "Q19859696",
                                       "Q20165762",
                                       "Q18021149",
                                       "Q18024284",
                                       "Q21946847",
                                       "Q7302597",
                                       "Q15729061",
                                       "Q2148098",
                                       "Q20973482",
                                       "Q2206158",
                                       "Q3991190",
                                       "Q9607200",
                                       "Q21488862",
                                       "Q15078704",
                                       "Q11344858",
                                       "Q7676468",
                                       "Q21493000",
                                       "Q18845468",
                                       "Q18845477",
                                       "Q18845460",
                                       "Q16533070",
                                       "Q17607805",
                                       "Q3328894",
                                       "Q18845466",
                                       "Q7493223",
                                       "Q18845459",
                                       "Q5967861",
                                       "Q19988235",
                                       "Q5743760",
                                       "Q6501139",
                                       "Q8033634",
                                       "Q12060197",
                                       "Q3442701",
                                       "Q7498074",
                                       "Q3773309",
                                       "Q11709897",
                                       "Q12770214",
                                       "Q5933633",
                                       "Q18176506",
                                       "Q10664184",
                                       "Q19348310",
                                       "Q3586055",
                                       "Q17125145",
                                       "Q20873224",
                                       "Q19831687",
                                       "Q18043172",
                                       "Q6476460",
                                       "Q14935820",
                                       "Q18845470",
                                       "Q18845481",
                                       "Q19859666",
                                       "Q20505696",
                                       "Q18016437",
                                       "Q21175365",
                                       "Q2825460",
                                       "Q2275519",
                                       "Q15823817",
                                       "Q19832979",
                                       "Q2099028",
                                       "Q17232171",
                                       "Q12981816",
                                       "Q3673080",
                                       "Q12810035",
                                       "Q18479425",
                                       "Q2787300",
                                       "Q8359102",
                                       "Q2843465",
                                       "Q15768813",
                                       "Q3176003",
                                       "Q3379374",
                                       "Q3671799",
                                       "Q15804599",
                                       "Q11821803",
                                       "Q16662510",
                                       "Q6797331",
                                       "Q5886408",
                                       "Q7933435",
                                       "Q1723983",
                                       "Q3773313",
                                       "Q19609895",
                                       "Q21401372",
                                       "Q18211851",
                                       "Q15286913",
                                       "Q17389157",
                                       "Q2279708",
                                       "Q18845474",
                                       "Q18845480",
                                       "Q19859622",
                                       "Q20819740",
                                       "Q21680662",
                                       "Q21931849",
                                       "Q4055803",
                                       "Q4833975",
                                       "Q2502986",
                                       "Q13755981",
                                       "Q7646667",
                                       "Q16948358",
                                       "Q6398999",
                                       "Q17093704",
                                       "Q7180555",
                                       "Q3034652",
                                       "Q7910446",
                                       "Q1673325",
                                       "Q8575029",
                                       "Q18845465",
                                       "Q15068894",
                                       "Q13382597",
                                       "Q5096989",
                                       "Q19689939",
                                       "Q11050561",
                                       "Q5620375",
                                       "Q5110573",
                                       "Q7855787",
                                       "Q7287800",
                                       "Q4955727",
                                       "Q488138",
                                       "Q2334238",
                                       "Q1320484",
                                       "Q5672008",
                                       "Q15088568",
                                       "Q15831340",
                                       "Q17505355",
                                       "Q19859574",
                                       "Q7813516",
                                       "Q21849792"
                                     ])
  end

  def serialize(quad)
    @file << "#{quad.map{|x| @writer.format_term(x)}.join(' ')} .\n"
  end


  def parse_labels(subject, doc)
    doc['labels'].each_value do |value|
      value_literal = RDF::Literal.new(value['value'], language: value['language'])
      serialize [subject, @rdfs.label,     value_literal]
    end
  end

  def parse_descriptions(subject, doc)
    doc['descriptions'].each_value do |value|
      value_literal = RDF::Literal.new(value['value'], language: value['language'])
      serialize [subject, @rdfs.description, value_literal]
    end
  end

  def parse_aliases(subject, doc)
    doc['aliases'].each_value do |xs|
      xs.each do |x|
        alias_literal = RDF::Literal.new(x['value'], language: x['language'])
        serialize [subject, @skos.altLabel, alias_literal]
      end
    end
  end

  def parse_claims(subject, doc)
    doc['claims'].each_value do |claims|
      claims.each do |claim|
        parse_claim subject, claim
      end
    end
  end

  def item_without_page?(claim)
    mainsnak = claim['mainsnak']
    mainsnak['datatype'] == 'wikibase-item' and @entities_without_page.include? "Q#{mainsnak['datavalue']['value']['numeric-id']}"
  end
  
  def parse_claim(subject, claim)
    if claim['type'] == 'statement' and claim['mainsnak']['snaktype'] == 'value'
      unless item_without_page?(claim)
        property  = @p[claim['mainsnak']['property']]
        statement = @wds[claim['id'].sub('$','--').sub(/^q/,'Q')]
      
        triples = []
        triples << [statement, @rdf.type, @wikibase.Statement]

        object    = atomic_snak(claim['mainsnak'])
        if object.nil?
          object  = @wdv[claim['id'].sub('$','--').sub(/^q/,'Q')]
          complex_snak(claim['mainsnak']).each do |pair|
            triples << [object] + pair
          end
        end

        case @mode
        when :naryrel
          ps = property
          pv = @ps[claim['mainsnak']['property']]
          triples << [subject, ps, statement]
          triples << [statement, pv, object]
        when :stdreif
          triples << [statement, @rdf.subject,   subject]
          triples << [statement, @rdf.predicate, property]
          triples << [statement, @rdf.object,    object]
        when :sgprop
          triples << [subject, statement, object]
          triples << [statement, @rdf.singletonPropertyOf, property]
        when :rdr
          rdr_triple = "<<"+triple_to_string([subject, property, object])+" >> "+triple_to_string([@wikibase.hasSID,statement])+" .\n" #todo check if to_s works
        when :ngraphs
          triples << [subject, property, object]
        end

        parse_qualifiers(claim).each do |pair|
          case pair.size
          when 2
            triples << [statement] + pair
          when 3
            triples << pair
          end
        end

        triples.each { |triple| triple << statement } if @mode == :ngraphs
        triples.each { |triple| serialize triple } 
        @file << rdr_triple if @mode == :rdr #write rdr triple directly to file
             
      end
    end
  end
  
  def triple_to_stringb(triple)
    output = RDF::Writer.for(:ntriples).buffer do |writer|
      writer << triple  
    end
    return output.chomp.chomp('.') #cut off newline and .
  end
  
  def triple_to_string(triple)
    return "#{triple.map{|x| @writer.format_term(x)}.join(' ')}"
  end
  
  def triples_to_string(triples)
    output = RDF::Writer.for(:ntriples).buffer do |writer|
      triples.each { |triple|
              writer << triple
              puts triple
            } 
    end
  end

  def parse_qualifiers(claim)
    triples = []
    unless claim['qualifiers'].nil?
      claim['qualifiers'].each_value do |qualifiers|
        qualifiers.each do |qualifier|
          if qualifier['snaktype'] == 'value'
            object = atomic_snak(qualifier)
            if object.nil?
              object = @pq[qualifier['hash']]
              complex_snak(qualifier).each do |pair|
                triples << [object] + pair
              end
            end
            triples << [@p[qualifier['property']], object]
          end
        end
      end
    end
    triples
  end

  def atomic_snak(mainsnak)
    case mainsnak['datatype']
    when 'string'  
      RDF::Literal.new(mainsnak['datavalue']['value'])
    when 'monolingualtext'
      RDF::Literal.new(mainsnak['datavalue']['value']['text'],
                       language: mainsnak['datavalue']['value']['language'])
    when 'wikibase-item'
      @wd["Q#{mainsnak['datavalue']['value']['numeric-id']}"]
    when 'wikibase-property'
      @p["Q#{mainsnak['datavalue']['value']['numeric-id']}"]
    when 'commonsMedia'
      @commons[mainsnak['datavalue']['value']]
    when 'url'
      RDF::URI.new mainsnak['datavalue']['value']
    else
      nil
    end
  end

  def complex_snak(mainsnak)
    pairs = []
    case mainsnak['datatype']
    when 'time'
      value = mainsnak['datavalue']['value']
      pairs << [@rdf.type,                   @wikibase.TimeValue]
      pairs << [@wikibase.timeValue,         RDF::Literal::DateTime.new(value['time'])]
      pairs << [@wikibase.timeTimeZone,      RDF::Literal::Integer.new(value['timezone'])]
      pairs << [@wikibase.timePrecision,     RDF::Literal::Integer.new(value['precision'])]
      pairs << [@wikibase.timeCalendarModel, RDF::URI.new(value['calendarmodel'])]
    when 'quantity'
      value = mainsnak['datavalue']['value']
      pairs << [@rdf.type,                    @wikibase.QuantityValue]
      pairs << [@wikibase.quantityValue,      RDF::Literal::Decimal.new(value['amount'])]
      pairs << [@wikibase.quantityUnit,       RDF::Literal.new(value['unit'])]
      pairs << [@wikibase.quantityUpperBound, RDF::Literal::Decimal.new(value['upperBound'])]
      pairs << [@wikibase.quantityLowerBound, RDF::Literal::Decimal.new(value['lowerBound'])]
    when 'globe-coordinate'
      value = mainsnak['datavalue']['value']
      pairs << [@rdf.type,           @wikibase.GlobeCoordinate]
      pairs << [@wikibase.latitude,  RDF::Literal::Decimal.new(value['latitude'])]
      pairs << [@wikibase.longitude, RDF::Literal::Decimal.new(value['longitude'])]
      pairs << [@wikibase.alttitude, RDF::Literal::Decimal.new(value['alttitude'])]
      pairs << [@wikibase.precision, RDF::Literal::Decimal.new(value['precision'])]
      pairs << [@wikibase.globe,     RDF::URI.new(value['globe'])]
    end
    pairs
  end

  def translate(doc)
    @doc = doc
    case doc['type']
    when 'item'
      subject = @wd[doc['id']]
      serialize [subject, @rdf.type, @wikibase.Item]
    when 'property'
      subject = @p[doc['id']]
      serialize [subject, @rdf.type, @wikibase.Property]
      if @mode == :naryrel
        serialize [subject, @wikibase.propertyValue, @ps[doc['id']]]
      end
   end
   parse_labels        subject, doc
   parse_descriptions  subject, doc
   parse_aliases       subject, doc
   parse_claims        subject, doc
  end
end
