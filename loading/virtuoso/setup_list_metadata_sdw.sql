-- Deleting previous entries of loader script
delete from DB.DBA.load_list;
--      <folder with data>  <pattern>    <default graph if no graph file specified>
LD_Dir ('/home/benchmark/data2/wikidata/wikibase-bench/wikidata/sdw/metadata/', '*.gz', 'http:/metadata.org');
checkpoint;
commit WORK;
checkpoint;
EXIT;
