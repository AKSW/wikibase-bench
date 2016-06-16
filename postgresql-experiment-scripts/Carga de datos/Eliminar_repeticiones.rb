require 'pg'
require 'active_record'
start = Time.now
conn = PG::Connection.open(:dbname => 'wikidata')
consultas = ['SELECT id FROM entities;']
items=Array.new(19000000)
properties=Array.new(19000000) ## son properties
i = 0
consultas.each do |query|
  begin
    res = conn.exec(query)
    res.each do |ans|
      entitie= ans['id'].slice!(0)
      if entitie== 'Q'
        items[ans['id'].to_i] = 1
      elsif entitie== 'P'
        properties[ans['id'].to_i] = 1
      end
    end
  rescue Exception => e
    puts query
    puts e.to_s
  end
end
finish = Time.now
puts start-finish
conn.close
ActiveRecord::Base.establish_connection(
    adapter: 'postgresql',
    database: 'wikidata',
    pool: 5
)

class Claim < ActiveRecord::Base
  self.table_name = "claims"

end

class Qualifier < ActiveRecord::Base
  self.table_name = "qualifiers"

end

class Entity < ActiveRecord::Base
  self.table_name = "entities"
end




def clean_claim_property(propertiessarray)
  errorclaimvid = File.open("CLAIMS_PROPERTY_FAILED.txt", "a")
  i =0
  start = Time.now
  Claim.find_each(batch_size: 10000)  do |claim|
    array_property_value = claim.property[1..-1].to_i
    if propertiesarray[array_property_value] != 1
      puts claim.id + ' ' +  claim.datavalue_entity
      errorclaimvid << claim.id + ' ' +  claim.datavalue_entity
      #claim.destroy_all

    end
    if i%1000000==0
      finish = Time.now
      puts finish-start
    end
    i+=1
  end
end


def clean_claim_datavalue_entity_id(itemssarray)
  errorclaimvid = File.open("CLAIMS_DATAVALUEENTITY_FAILED.txt", "a")
  i =0
  start = Time.now
  Claim.find_each(batch_size: 10000)  do |claim|
    array_property_value = claim.datavalue_entity[1..-1].to_i
    if itemsarray[array_property_value] != 1
      puts claim.id + ' ' +  claim.datavalue_entity
      errorclaimvid << claim.id + ' ' +  claim.datavalue_entity
      #claim.destroy_all

    end
    if i%1000000==0
      finish = Time.now
      puts finish-start
    end
    i+=1
  end
end


def clean_qualifier_datavalue_entity_id(itemssarray)
  errorclaimvid = File.open("QUALIFIERS__FAILED.txt", "a")
  i =0
  start = Time.now
  QUalifier.find_each(batch_size: 10000)  do |qualifier|
    array_property_value = qualifier.datavalue_entity[1..-1].to_i
    if itemsarray[array_property_value] != 1
      puts 'Entidad faltante ' +  qualifier.datavalue_entity
      errorclaimvid << 'Entidad faltante ' +  qualifier.datavalue_entity
      #claim.destroy_all

    end
    if i%1000000==0
      finish = Time.now
      puts finish-start
    end
    i+=1
  end
end


def clean_qualifier_property(propertiessarray)
  errorclaimvid = File.open("QUALIFIER_PROPERTY_FAILED.txt", "a")
  i =0
  start = Time.now
  Qualifier.find_each(batch_size: 10000)  do |qualifier|
    array_property_value = qualifier.property[1..-1].to_i
    if propertiesarray[array_property_value] != 1
      puts 'Propiedad faltante ' +  qualifier.datavalue_entity
      errorclaimvid << 'Propiedad faltante ' +  qualifier.datavalue_entity
      #claim.destroy_all

    end
    if i%1000000==0
      finish = Time.now
      puts finish-start
    end
    i+=1
  end
end


def clean_qualifier_qproperty(propertiessarray)
  errorclaimvid = File.open("QUALIFIER_PROPERTY_FAILED.txt", "a")
  i =0
  start = Time.now
  Qualifier.find_each(batch_size: 10000)  do |qualifier|
    array_property_value = qualifier.qualifier_property[1..-1].to_i
    if propertiesarray[array_property_value] != 1
      puts 'Propiedad faltante ' +  qualifier.datavalue_entity
      errorclaimvid << 'Propiedad faltante ' +  qualifier.qualifier_property 
      #claim.destroy_all

    end
    if i%1000000==0
      finish = Time.now
      puts finish-start
    end
    i+=1
  end
end



begin
  clean_qualifier_qproperty(properties)
  clean_qualifier_property(properties)
  clean_qualifier_datavalue_entity_id(items)
  clean_claim_datavalue_entity_id(items)
  clean_claim_property(properties)

rescue Exception => e
  puts e
end


