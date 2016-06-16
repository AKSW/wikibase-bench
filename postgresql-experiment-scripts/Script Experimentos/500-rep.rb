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

#method for queries combination and select the proper query
def combinations (quin, combination)
    
    statements =
    [
        "claims.entity_id = ",
        "claims.property = ",
        "claims.datavalue_entity = ",
        "qualifiers.qualifier_property = ",
        "qualifiers.datavalue_entity = "
    ]

    query = ""

    combination.each do |vals|
        query += statements[vals] +"'"+quin[vals]+"'"+ " AND "
    end
    query_parameters = query.slice(0..-6)
    if combination.include?(3) || combination.include?(4)
        return 'SELECT claims.entity_id AS Subject, claims.property AS Predicate, claims.datavalue_entity AS Object, qualifiers.qualifier_property AS Qualifier_property, qualifiers.datavalue_entity AS Qualifier FROM claims, qualifiers WHERE claims.id = qualifiers.claim_id AND '+ query_parameters +'LIMIT 10000' 
    else
        return 'SELECT Claim_data.Subject, Claim_data.Predicate, Claim_data.Object, Qualifier_data.Qualifier_property, Qualifier_data.datavalue_entity FROM (SELECT claims.id AS Main_claim_id, claims.entity_id AS Subject, claims.property AS Predicate, claims.datavalue_entity AS Object FROM claims WHERE '+ query_parameters +') AS Claim_data LEFT OUTER JOIN (SELECT claim_id, qualifier_property, datavalue_entity  FROM qualifiers) AS Qualifier_data ON ( Claim_data.Main_claim_id = Qualifier_data.claim_id) LIMIT 10000' 
    end
end

#create output file
results = File.open("results.txt", "a")
control = File.open("control.txt", "a")
results << "Overall time BD (ms)"+"\t"+"Overall time SO (ms)"+"\t"+"Time first output SO (ms)"+"\t"+"number of tuples"+"\t" +"Exceptions"+"\n"

#set vars
puts 'Begin'
i=1;
j=1;
isconnected = false
conn = nil
last_quin = nil

#31 query_combinations
query_combinations =
[
    [0],
    [1],
    [0,1],
    [2],
    [0,2],
    [1,2],
    [0,1,2],
    [3],
    [0,3],
    [1,3],
    [0,1,3],
    [2,3],
    [0,2,3],
    [1,2,3],
    [0,1,2,3],
    [4],
    [0,4],
    [1,4],
    [0,1,4],
    [2,4],
    [0,2,4],
    [1,2,4],
    [0,1,2,4],
    [3,4],
    [0,3,4],
    [1,3,4],
    [0,1,3,4],
    [2,3,4],
    [0,2,3,4],
    [1,2,3,4],
    [0,1,2,3,4]
]
#SELECT claims.entity_id AS Subject, claims.property AS Predicate, claims.datavalue_entity AS Object, qualifiers.qualifier_property AS Qualifier_property, qualifiers.datavalue_entity AS Qualifier FROM claims, qualifiers WHERE claims.id = qualifiers.claim_id AND claims.entity_id = 'Q3112657' LIMIT 10000;


#count the queries
query_counter = 0;

#main method
File.open("./quins.csv", "r") do |f|
  f.each_line do |line|

    #if there is not a previus connection, connect to the db
    if !isconnected
        puts 'connecting to db: '+j.to_s
        if (j%2==0)
            conn = PGconn.open(:dbname => 'wikidata') 
        else
            conn = PGconn.open(:dbname => 'wikidata_v2')
        end

        isconnected = true
    end

    #separing the entities from the quin
    quins_values = line.split(' ')
    last_quin = 'quin: ' + quins_values[0] +' '+ quins_values[1] +' '+ quins_values[2]+' ' +quins_values[3] +' '+quins_values[4]

    query = combinations( quins_values , query_combinations[j-1])
    #UnComment in local enviroment
    #query="SELECT * FROM entities"

    #excec the query an measure the time
    exceptions = 'none'
    diff='none'
    #puts query.to_s
    begin
        start = Time.now
        res  = conn.exec(query)
        finish = Time.now
        #Time in miliseconds
        diff = ((finish - start)).round(6).to_s
    rescue Exception => e
        exceptions = "Time Error"
    end


    begin
        total_output=res.num_tuples.to_s
    rescue Exception => e
        total_output='0'
    end

    results << 'N/A'+"\t"+diff+"\t"+'N/A'+"\t"+total_output+"\t"+exceptions.to_s+"\n"
    exceptions = 'none'

    i+=1
    #if the group of queries is done, reset the server
    if i>500
        conn.close
        isconnected = false
        system( "/usr/lib/postgresql/9.1/bin/pg_ctl restart -D /home/eczerega/database" )
        sleep 10
        system( "echo ' '" )
        i=1
        j+=1
    end

    #excec the script until the last query is done
    if i==250
     control << j.to_s+') quin: ' + quins_values[0] +' '+ quins_values[1] +' '+ quins_values[2]+' ' +quins_values[3] +' '+quins_values[4] + "\t"+ " query: "+ query + "\t" + res.values.to_s + "\n"
    end

    if j>31
        break
    end
    query_counter+=1
  end
end
control << last_quin
#print some data to ensure the numbers are correct
puts 'last_quin: '+ last_quin
puts 'queries: ' + j.to_s
puts 'queries excecuted: ' + query_counter.to_s



