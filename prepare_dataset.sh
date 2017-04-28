WD_HOME=/home/benchmark/data2/wikidata/wikibase-bench
RDF=/home/benchmark/data2/wikidata/wikidata-files
DATASET=/home/benchmark/data2/wikidata/wikidata20160104.json.bz2
cd $RDF
#bunzip2 -c $DATASET | split -d -a 3 -C 100000000
#bunzip2 -c $DATASET | split -d -a 3 -C 100000000 --additional-suffix=.json --filter='gzip > $FILE.gz'
#rename '/$/.json/' x*
#gzip x*.json
cd $WD_HOME
translation/translate_all.rb $RDF
