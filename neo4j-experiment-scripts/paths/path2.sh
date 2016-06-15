#!/bin/bash

# -*- ENCODING: UTF-8 -*-

#Encendiendo Neo4j
../neo4j/bin/neo4j start

python path2.py

#Apagando Neo4j
../neo4j/bin/neo4j stop

exit
