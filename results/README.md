# Results

This folder (`results`) contain the experiment results. The folders
`quins` and `paths` contain respectively ellapsed times for queries
that are generated with quins or with snowflake parameters.

## Results of quin queries

The folder `quins` is organized in several folders that have the
engine as prefix and the schema as suffix. For example, the folder
`blazegraph-onaryrel` store the results for experiments done in
Blazegraph using the n-ary relations schema.

Inside this folder there are 31 CSV files that have the bitmask
corresponding to the queries. For example, the file
`results_blazegraph_onaryrel_00001.csv` contains the results
associated to queries with the bitmask `00001`.

The rows of the CSV file are structured as:

```
BEGIN: 2016-04-25 01:00:17 -0300
onaryrel,00001,0,24.488325925,4416,200
onaryrel,00001,1,0.047904509,1,200
onaryrel,00001,2,0.043643808,1,200
onaryrel,00001,3,0.043876248,1,200
onaryrel,00001,4,0.138916685,17,200
onaryrel,00001,5,0.042950497,1,200
onaryrel,00001,6,0.064501841,7,200
onaryrel,00001,7,0.041367219,1,200
...
END: 2016-04-25 01:21:21 -0300
```

The first column, represents the schema used (in this case
n-ary-relations). The second column, the bitmask (in this case
`00001`). The third column represent the row of the quins file that is
used. The fourth column is the ellapsed time of executing the
query. The fifth column is the number of solutions returned (queries
have a limit of 10000). Finally, the sixth column is the status of the
evaluation (200 means that the execution was successful).

The number of queries is used to check that results are the same in
all models.

The results of Neo4j are stored in the folder `neo4j`. They have a
different format:

```
['Q4123253', 'P19', 'Q1899', 'P17', 'Q15180'] 0,0,0,timed out- time elapsed:60.1942009926
['Q17323865', 'P186', 'Q226697', 'P518', 'Q861259'] 0,0,0,timed out- time elapsed:60.0625450611
4.72560787201,3.30618691444,10000,OK
1.03309583664,1.02391695976,45,OK
0.616970062256,0.615936040878,5,OK
0.270227193832,0.269872188568,2,OK
```

When a query evaluation fails, then the quin is printed, as in the first two
rows. On the contrary, if the query evaluation success, then the row
is printed with four columns: the elapsed time by the script, the
elapsed time by the engine, the number of solutions and the status (OK
if success).

The result for PostgreSQL are published in the file
`postgresql.csv`. The rows have five columns. Columns one, three and
five do not apply. Column two is the elapsed time and column four is
the number of solutions.

## Results of snowflake queries

Results of snowflake queries are published in the folder paths. The
format is similar that the used for quin queries. However, the second
column stores the size of the snowflake instead of the bitmask.
