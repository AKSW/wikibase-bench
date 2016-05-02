#!/bin/bash

# -*- ENCODING: UTF-8 -*-

for i in {1..31}
do
    if [ $((i%2)) -eq 0 ];
    then
        ../neo4j/bin/neo4j start
        python queries.py $i
        ../neo4j/bin/neo4j stop
    else
        ../neo4j2/bin/neo4j start
        python queries.py $i
        ../neo4j2/bin/neo4j stop
    fi
done

exit
