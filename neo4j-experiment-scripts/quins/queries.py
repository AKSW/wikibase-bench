#!/usr/bin/python

from py2neo import Graph
from py2neo.packages.httpstream import http
import time
import sys
import os

def get_quin_filename(p):
    return './quin-patterns/quin-patterns-'+str(p[0])+str(p[1])+str(p[2])+str(p[3])+str(p[4])+'.csv'

def get_where(n, n_id):
    if n == 0:
        return "s.id='" + str(n_id) + "' "
    elif n == 1:
        return "p.id='" + str(n_id) + "' "
    elif n == 2:
        return "o.id='" + str(n_id) + "' "
    elif n == 3:
        return "qp.id='" + str(n_id) + "' "
    elif n == 4:
        return "q.id='" + str(n_id) + "' "
    else:
        return ""

# recibe una permutacion (e.g. [1,0,0,1,0]) y un quin (e.g. [Q1,P1,Q2,P2,Q3])
# y retorna la query correspondiente en cypher
def get_query(permutation_array, quin):
    
    if permutation_array[2] == 1:
        o_type = ':Item'
    else:
        o_type = ''

    if permutation_array[4] == 1:
        q_type = ':Item'
    else:
        q_type = ''

    query = 'MATCH (s:Entity)-[:PROP_FROM]->(c:Claim)-[:PROP_TO]->(o' + o_type + '),(c)-[:PROPERTY]->(p:Property)'

    if permutation_array[3] == 1 or permutation_array[4] == 1:
        query += ',(c)-[:QUAL_FROM]->(qn:Qualifier)-[:QUAL_TO]->(q' + q_type + '),(qn)-[:PROPERTY]->(qp:Property) WHERE '
        is_first = True

        for i in range(5):
            if permutation_array[i] == 0:
                continue

            if is_first:
                is_first = False
                query += get_where(i, quin[i])

            else:
                query += 'AND ' + get_where(i, quin[i])

    else:
        query += ' WHERE '
        is_first = True

        for i in range(3):
            if permutation_array[i] == 0:
                continue

            if is_first:
                is_first = False
                query += get_where(i, quin[i])

            else:
                query += 'AND ' + get_where(i, quin[i])
        
        query += 'OPTIONAL MATCH (c)-[:QUAL_FROM]->(qn:Qualifier)-[:QUAL_TO]->(q),(qn)-[:PROPERTY]->(qp:Property) '

    query += 'RETURN s.id,p.id,o.value,o.id,qp.id,q.value,q.id LIMIT 10000'
    #query += 'RETURN s.id,p.id,o.value,o.id,qp.id,q.value,q.id LIMIT 1'
    return query


permutation_array = {1  : [1,0,0,0,0],
                     2  : [0,1,0,0,0],
                     3  : [1,1,0,0,0],
                     4  : [0,0,1,0,0],
                     5  : [1,0,1,0,0],
                     6  : [0,1,1,0,0],
                     7  : [1,1,1,0,0],
                     8  : [0,0,0,1,0],
                     9  : [1,0,0,1,0],
                     10 : [0,1,0,1,0],
                     11 : [1,1,0,1,0],
                     12 : [0,0,1,1,0],
                     13 : [1,0,1,1,0],
                     14 : [0,1,1,1,0],
                     15 : [1,1,1,1,0],
                     16 : [0,0,0,0,1],
                     17 : [1,0,0,0,1],
                     18 : [0,1,0,0,1],
                     19 : [1,1,0,0,1],
                     20 : [0,0,1,0,1],
                     21 : [1,0,1,0,1],
                     22 : [0,1,1,0,1],
                     23 : [1,1,1,0,1],
                     24 : [0,0,0,1,1],
                     25 : [1,0,0,1,1],
                     26 : [0,1,0,1,1],
                     27 : [1,1,0,1,1],
                     28 : [0,0,1,1,1],
                     29 : [1,0,1,1,1],
                     30 : [0,1,1,1,1],
                     31 : [1,1,1,1,1]
                     }

graph = Graph()


i = int(sys.argv[1])

# creo el archivo donde se guardara el output
folder_name = './no-timeout-experimental'
output_file_name = folder_name + '/query_' + str(i)
if not os.path.exists(folder_name):
        os.makedirs(folder_name)
output_file = open(output_file_name, 'w')

# leo el archivo
quins_file = open(get_quin_filename(permutation_array[i]), 'r')

# ahora hago las 300 consultas
for j in range(300):
    # leo el quin
    current_line = quins_file.readline()
    quin         = current_line.split()
    query        = get_query(permutation_array[i], quin)
    http.socket_timeout = 9999

    # empieza cronometro
    number_of_tuples = 0
    start = time.time()
    try:
        for record in graph.cypher.stream(query):
            number_of_tuples += 1
        total_time = time.time()
        #Overal time, number of tuples, Exceptions"
        output_file.write(str(total_time-start)+','+str(number_of_tuples)+',OK\n')

    except Exception as inst:
        exception_time = time.time()
        output_file.write(str(exception_time-start)+','+str(number_of_tuples)+','+str(inst)+'\n')

#cierro los archivo
quins_file.close()
output_file.close()
