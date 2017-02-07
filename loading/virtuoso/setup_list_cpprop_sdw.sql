-- Deleting previous entries of loader script
delete from DB.DBA.load_list;
--      <folder with data>  <pattern>    <default graph if no graph file specified>
Ld_dir ('/home/benchmark/data2/wikidata/wikibase-bench/wikidata/sdw/cpprop', '*.gz', 'http://data.org');
checkpoint;
commit WORK;
checkpoint;
EXIT;
