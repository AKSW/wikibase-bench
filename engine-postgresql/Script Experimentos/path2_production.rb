#------------------------------------------------------------------------------ 
# Pg configuration    
# pgtune for version 8.4 run on 2016-03-09      
# Based on 32912036 KB RAM, platform Linux, 100 clients and mixed workload      
#------------------------------------------------------------------------------     

#default_statistics_target = 100     
#maintenance_work_mem = 1920MB       
#checkpoint_completion_target = 0.9      
#effective_cache_size = 22GB     
#work_mem = 160MB        
#wal_buffers = 16MB           
#shared_buffers = 7680MB
#default_transaction_isolation = 'read uncommitted'
#statement_timeout = 60010  

require 'pg'

require 'json'
freno =1

results = File.open("results2.txt", "a")
results << "Overall time BD (ms)"+"\t"+"Overall time SO (ms)"+"\t"+"Time first output SO (ms)"+"\t"+"number of tuples"+"\t" +"Exceptions"+"\n"
results.close
conn = PGconn.open(:dbname => 'wikidata')

File.open("./path_2.json", "r") do |f|
  f.each_line do |line|
	freno +=1
	if freno > 301
		break
	end
  	data = JSON.parse(line)
  	#data = JSON.parse('[{"entity_id":"Q3938556","claims":[["P735","Q15905580"],["P734",0],["P31",0]],"property":"P27"},{"entity_id":"Q96","claims":[["P530","Q183"],["P530","Q155"],["P530",1],["P361",0]]}]')
  	puts data
  	proyection_clause = 'SELECT path_1.entity_id, '
	from_clause = ' FROM claims AS path_1, '
	property=nil
	where_clause1 = ''
	where_clause2 = ''
	join_clause1 = ' WHERE '
	join_clause2 = ''
	join_main_entities = ''
	first_pid=nil
	first_id=nil
  	i=1
	claim_id=1
  	data.each do |claims|
  		claim_json=claims.to_json
  		claim_json = JSON.parse(claim_json)  
  		data_id=1
  		if  claim_json["property"] != '' && claim_json["property"] != nil
  			property = claim_json["property"]  	
  		end
  		identifiers=Array.new()
	  	claim_json["claims"].each do |rays|
	  		identifier = 'C'+claim_id.to_s+data_id.to_s
	  		puts identifier
	  		if claim_id==1 && data_id==1
	  			first_pid = 'C'+claim_id.to_s+data_id.to_s
	  		end
	  		if claim_id==2 && data_id==1
	  			first_id = 'C'+claim_id.to_s+data_id.to_s
	  		end
	  		identifiers.push(identifier)
	  		claim_as = 'claims AS C'+claim_id.to_s+data_id.to_s+','
	  		from_clause = from_clause + claim_as
	  		if rays[1]!=1 && rays[1]!=0
	  			proyection_clause = proyection_clause + 'C'+claim_id.to_s+data_id.to_s+'.datavalue_entity, '
	  			if claim_id==1
	  				where_clause1 = where_clause1+'C'+claim_id.to_s+data_id.to_s+'.property=\''+rays[0].to_s+'\' AND '+' C'+claim_id.to_s+data_id.to_s+'.datavalue_entity=\''+rays[1]+ '\' AND '
	  			else
					where_clause2 = where_clause2+'C'+claim_id.to_s+data_id.to_s+'.property=\''+rays[0].to_s+'\' AND '+' C'+claim_id.to_s+data_id.to_s+'.datavalue_entity=\''+rays[1]+ '\' AND '  			
	  			end
	  		else
	  			if claim_id==1
	  				where_clause1 = where_clause1+'C'+claim_id.to_s+data_id.to_s+'.property=\''+rays[0].to_s+ '\' AND '
	  			else
		  			where_clause2 = where_clause2+'C'+claim_id.to_s+data_id.to_s+'.property=\''+rays[0].to_s+ '\' AND '
	  			end
	  		end
	  		data_id+=1
		end
		for u in 1..identifiers.size
			for v in u+1..identifiers.size
				if claim_id==1
				   join_clause1 += identifiers[u-1].to_s + '.entity_id = ' + identifiers[v-1].to_s + '.entity_id AND '
				else
				   join_clause2 += identifiers[u-1].to_s + '.entity_id = ' + identifiers[v-1].to_s + '.entity_id AND '
				end
			end
		end
		claim_id+=1
  	end
  	entire_query=''
    from_clause = from_clause.chop
	proyection_clause = proyection_clause.chop.chop
	where_clause1 = where_clause1.chop.chop.chop.chop
	where_clause2 = where_clause2.chop.chop.chop.chop
	where_clause2 = where_clause2
	if first_pid != nil && first_pid != ''
		join_main_entities = 'AND path_1.entity_id='+first_pid.to_s+'.entity_id '		
	end

	#puts proyection_clause
	entire_query = entire_query +  proyection_clause
	#puts from_clause
	entire_query = entire_query + from_clause
	#puts join_clause1
	entire_query = entire_query + join_clause1
	#puts where_clause1
	entire_query = entire_query + where_clause1
	#puts join_main_entities
	entire_query = entire_query + join_main_entities
	if property != nil
		if first_id != nil && first_id != ''
			union = 'AND path_1.datavalue_entity='+first_id+'.entity_id AND path_1.property=\''+ property+'\' AND '
		else
			union = 'AND path_1.property=\''+ property+'\' AND '
		end
		entire_query = entire_query + union
		#puts union
	end
	if join_clause2!=''
		entire_query = entire_query + join_clause2 
	   #puts join_clause2 
	end	
	if where_clause2!=''
		entire_query = entire_query + where_clause2
	   #puts where_clause2
	end
	entire_query = entire_query + ';'
	if entire_query.include? 'AND ;'
		entire_query= entire_query.chop.chop.chop.chop.chop
		entire_query=entire_query+';'
	end
	if entire_query.include? 'WHERE AND'
		entire_query= entire_query.sub('WHERE AND', "WHERE")
	end
	puts freno.to_s+ ') ' + entire_query
	
	begin
        start = Time.now
        res  = conn.exec(entire_query)
        finish = Time.now
        diff = ((finish - start)).round(6).to_s
		total_output=res.num_tuples.to_s
		results = File.open("results2.txt", "a")
	    results << 'N/A'+"\t"+diff+"\t"+'N/A'+"\t"+total_output+"\t"+'OK'+"\n"
	    puts 'SISISIISISISISISISIS'
	    results.close
	rescue Exception => e
		results = File.open("results2.txt", "a")
	    results << 'N/A'+"\t"+'60'+"\t"+'N/A'+"\t"+'0'+"\t"+'timed out'+"\n"
	    puts e
	    results.close

	end

  end
end


#SELECT C1.entity_id ,C1.datavalue_entity ,C2.datavalue_entity  FROM (SELECT * FROM claims WHERE property='P27') AS C1,(SELECT * FROM claims WHERE property='P69') AS C2 WHERE C1.entity_id = C2.entity_id
#ruby ./path2_production.rb



#SELECT * FROM (SELECT C1.entity_id , C1.property ,C3.datavalue_entity  FROM (SELECT * FROM claims WHERE property='P39' AND datavalue_entity= 'Q19362907') AS C1,(SELECT * FROM claims WHERE property='P735') AS C2,(SELECT * FROM claims WHERE property='P27') AS C3 WHERE C1.entity_id = C2.entity_id AND C1.entity_id = C3.entity_id AND C2.entity_id = C3.entity_id ) AS NODE1,(SELECT C1.entity_id , C1.property  FROM  WHERE ) AS NODE2 WHERE NODE1.entity_id=NODE2.entity_id  ;





