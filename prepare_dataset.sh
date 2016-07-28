WD_HOME=/home/johannes/Desktop/Master/wikidata/wikidata-experiments
RDF=/home/johannes/Desktop/Master/wikidata/wikidata-test
DATASET=/home/johannes/Desktop/Master/wikidata/wikidata-dump/wikidata20160104.json.bz2
cd $RDF
#bunzip2 -c $DATASET | split -d -a 3 -C 100000000
bunzip2 -c $DATASET | split -d -a 3 -C 100000000 --additional-suffix=.json --filter='gzip > $FILE.gz'
#rename '/$/.json/' x*
#gzip x*.json
cd $WD_HOME
translation/translate_all.rb $RDF
