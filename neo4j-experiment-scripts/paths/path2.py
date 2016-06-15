#!/usr/bin/python

from py2neo import Graph
from py2neo.packages.httpstream import http
import time
import sys


import json

def get_query(claims1, claims2, prop):
    property_ids1 = []
    item_ids1     = []
    no_item_property_ids1           = []
    no_item_property_ids_no_return1 = []
    
    property_ids2 = []
    item_ids2     = []
    no_item_property_ids2           = []
    no_item_property_ids_no_return2 = []



    for claim in claims1:
        if claim[1] == 0:
            no_item_property_ids_no_return1.append(claim[0])
        elif claim[1] == 1:
            no_item_property_ids1.append(claim[0])
        else:
            property_ids1.append(claim[0])
            item_ids1.append(claim[1])

    for claim in claims2:
        if claim[1] == 0:
            no_item_property_ids_no_return2.append(claim[0])
        elif claim[1] == 1:
            no_item_property_ids2.append(claim[0])
        else:
            property_ids2.append(claim[0])
            item_ids2.append(claim[1])

    query = 'MATCH (qa:Item)-[:PROP_FROM]->(cab:Claim)-[:PROP_TO]->(qb:Item), (cab)-[:PROPERTY]->(:Property {id:"'+prop+'"})'
    i1 = 0
    j1 = 0
    k1 = 0
    i2 = 0
    j2 = 0
    k2 = 0

    for i1 in range(len(property_ids1)):
        query += ',(qa:Item)-[:PROP_FROM]->(c'+str(i1)+':Claim)-[:PROP_TO]->(:Item {id:"'+item_ids1[i1]+'"}),(c'+str(i1)+')-[:PROPERTY]->(:Property {id:"' + property_ids1[i1] + '"})'

    for j1 in range(len(no_item_property_ids1)):
        query += ',(qa:Item)-[:PROP_FROM]->(c'+str(i1+j1+1)+':Claim)-[:PROP_TO]->(q'+str(i1+j1+1)+':Item),(c'+str(i1+j1+1)+')-[:PROPERTY]->(:Property {id:"' + no_item_property_ids1[j1] + '"})'

    for k1 in range(len(no_item_property_ids_no_return1)):
        query += ',(qa:Item)-[:PROP_FROM]->(c'+str(i1+j1+k1+2)+':Claim)-[:PROP_TO]->(:Item),(c'+str(i1+j1+k1+2)+')-[:PROPERTY]->(:Property{id:"' + no_item_property_ids_no_return1[k1] + '"})'


    ####### segundo copo ################
    
    for i2 in range(len(property_ids2)):
        query += ',(qb:Item)-[:PROP_FROM]->(c'+str(i1+j1+k1+i2+3)+':Claim)-[:PROP_TO]->(:Item {id:"'+item_ids2[i2]+'"}),(c'+str(i1+j1+k1+i2+3)+')-[:PROPERTY]->(:Property {id:"' + property_ids2[i2] + '"})'

    for j2 in range(len(no_item_property_ids2)):
        query += ',(qb:Item)-[:PROP_FROM]->(c'+str(i1+j1+k1+i2+j2+4)+':Claim)-[:PROP_TO]->(q'+str(i1+j1+k1+i2+j2+4)+':Item),(c'+str(i1+j1+k1+i2+j2+4)+')-[:PROPERTY]->(:Property {id:"' + no_item_property_ids2[j2] + '"})'

    for k2 in range(len(no_item_property_ids_no_return2)):
        query += ',(qb:Item)-[:PROP_FROM]->(c'+str(i1+j1+k1+i2+j2+k2+5)+':Claim)-[:PROP_TO]->(:Item),(c'+str(i1+j1+k1+i2+j2+k2+5)+')-[:PROPERTY]->(:Property{id:"' + no_item_property_ids_no_return2[k2] + '"})'

    query += ' RETURN qa,qb'
    for j1 in range(len(no_item_property_ids1)):
        query += ',q' + str(i1+j1+1)
    for j2 in range(len(no_item_property_ids2)):
        query += ',q' + str(i1+j1+k1+i2+j2+4)
    query += ' LIMIT 10000'
    return query


path2 = open('path_2.json', 'r')
results = open('results_path2.csv', 'w')
graph = Graph()

for i in range(300):
    j = json.loads(path2.readline())
    claim1 = j[0]['claims']
    prop = j[0]['property']
    claim2 = j[1]['claims']
    query = get_query(claim1, claim2, prop)
    
    number_of_tuples = 0
    # http.socket_timeout = 9999
    start = time.time()
    try:
        for record in graph.cypher.stream(query):
            number_of_tuples += 1
        total_time = time.time()
        #Overal time, number of tuples, Exceptions"
        results.write(str(total_time-start)+','+str(number_of_tuples)+',OK\n')

    except Exception as inst:
        exception_time = time.time()
        results.write(str(exception_time-start)+','+str(number_of_tuples)+','+str(inst)+'\n')
  
path2.close()
results.close()
