#!/bin/bash

# -*- ENCODING: UTF-8 -*-

for i in {1..31}
do
    if [ $((i%2)) -eq 0 ];
    then
        $DB_1/bin/neo4j start
        python queries.py $i
        $DB_1/bin/neo4j stop
    else
        $DB_2/bin/neo4j start
        python queries.py $i
        $DB_2/bin/neo4j stop
    fi
done

exit
