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

require 'json'
begin
require 'pg'


results = File.open("results1.txt", "a")
results << "Overall time BD (ms)"+"\t"+"Overall time SO (ms)"+"\t"+"Time first output SO (ms)"+"\t"+"number of tuples"+"\t" +"Exceptions"+"\n"
results.close
conn = PGconn.open(:dbname => 'wikidata')
k=1
File.open("./path_1.json", "r") do |f|
  f.each_line do |line|
  	data = JSON.parse(line)
  	i=1

  	puts k.to_s
	k+=1
  	initial_project='SELECT C1.entity_id ,'
	project_acumulated = ''  
	subquerys='' 
	identifiers=Array.new	
  	data["claims"].each do |rays|
  		identifier = 'C'+i.to_s
  		if rays[1].to_s != '0' && rays[1].to_s != '1'
  			subquerys += '(SELECT * FROM claims WHERE property=\'' + rays[0].to_s + '\' AND datavalue_entity= \'' + rays[1].to_s + '\') AS '+identifier+','
		else
			if rays[1].to_s == '1'
				project_acumulated=project_acumulated+identifier+'.datavalue_entity ,'
			end
			subquerys += '(SELECT * FROM claims WHERE property=\'' + rays[0].to_s + '\') AS '+identifier+','
		end
		identifiers.push(identifier)
  		i+=1
	end
	projection = initial_project + project_acumulated
	projection=projection.chop + ' FROM ' 
	subquerys=subquerys.chop + ' WHERE '
	identifiers_size=identifiers.size
	counter =0
	ands=''
	for i in 1..identifiers_size
		for j in i+1..identifiers_size
		   ands += identifiers[i-1].to_s + '.entity_id = ' + identifiers[j-1].to_s + '.entity_id AND '
		end
	end
	ands = ands.chop.chop.chop.chop 
	ands= projection + subquerys + ands + ' LIMIT 10000;'
	if ands.include? "WHERE ;"
		ands = ands.chop.chop.chop.chop.chop.chop.chop.chop+' LIMIT 10000;' 
	end
	#puts ands


	begin
        start = Time.now
        res  = conn.exec(ands)
        puts ands
        finish = Time.now
        diff = ((finish - start)).round(6).to_s
		total_output=res.num_tuples.to_s
		results = File.open("results1.txt", "a")
	    results << 'N/A'+"\t"+diff+"\t"+'N/A'+"\t"+total_output+"\t"+'OK'+"\n"
	    results.close
	rescue Exception => e
		puts e
		results = File.open("results1.txt", "a")
	    results << 'N/A'+"\t"+'60'+"\t"+'N/A'+"\t"+'0'+"\t"+'timed out'+"\n"
	    results.close

	end


  end
end
conn.close
#ruby ./paths_production.rb

end



