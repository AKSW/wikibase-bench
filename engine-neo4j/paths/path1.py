#!/usr/bin/python

from py2neo import Graph
from py2neo.packages.httpstream import http
import time
import sys


import json

def get_query(claims):
    property_ids = []
    item_ids = []

    no_item_property_ids = []
    no_item_property_ids_no_return = []


    for claim in claims:
        if claim[1] == 0:
            no_item_property_ids_no_return.append(claim[0])
        elif claim[1] == 1:
            no_item_property_ids.append(claim[0])
        else:
            property_ids.append(claim[0])
            item_ids.append(claim[1])

    query = 'MATCH '
    first = True
    i = 0
    j = 0
    k = 0

    for i in range(len(property_ids)):
        if not first:
            query += ','
        else:
            first = False
        query += '(q:Item)-[:PROP_FROM]->(c'+str(i)+':Claim)-[:PROP_TO]->(:Item {id:"'+item_ids[i]+'"}),(c'+str(i)+')-[:PROPERTY]->(:Property {id:"' + property_ids[i] + '"})'

    for j in range(len(no_item_property_ids)):
        if not first:
            query += ','
        else:
            first = False
        query += '(q:Item)-[:PROP_FROM]->(c'+str(i+j+1)+':Claim)-[:PROP_TO]->(q'+str(i+j+1)+':Item),(c'+str(i+j+1)+')-[:PROPERTY]->(:Property {id:"' + no_item_property_ids[j] + '"})'

    for k in range(len(no_item_property_ids_no_return)):
        if not first:
            query += ','
        else:
            first = False
        query += '(q:Item)-[:PROP_FROM]->(c'+str(i+j+k+2)+':Claim)-[:PROP_TO]->(:Item),(c'+str(i+j+k+2)+')-[:PROPERTY]->(:Property{id:"' + no_item_property_ids_no_return[k] + '"})'

    query += 'RETURN q'
    for j in range(len(no_item_property_ids)):
        query += ',q' + str(i+j+1)
    query += ' LIMIT 10000'
    return query


path1 = open('path_1.json', 'r')
results = open('results1-no-timeout.csv', 'w')
graph = Graph()

for i in range(300):
    j = json.loads(path1.readline())
    claims = j['claims']
    query = get_query(claims)
    number_of_tuples = 0
    http.socket_timeout = 9999
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

path1.close()
results.close()
