-- Disabling auto index makes loading faster.
DB.DBA.VT_BATCH_UPDATE ('DB.DBA.RDF_OBJ', 'ON', NULL);
checkpoint;
commit WORK;
checkpoint;
EXIT;
