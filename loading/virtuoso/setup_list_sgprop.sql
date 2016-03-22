-- Deleting previous entries of loader script
delete from DB.DBA.load_list;
--      <folder with data>  <pattern>    <default graph if no graph file specified>
ld_dir ('/home/daniel/wikidata/dumps/wikidata_20160104', '*-sgprop.ttl.gz', 'http://wikidata.org');
