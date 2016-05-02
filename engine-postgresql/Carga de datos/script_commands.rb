require 'pg'
conn = PG::Connection.open(:dbname => 'wikidata')

commands = [

	'SELECT * FROM labels limit 10;',
	'COPY labels FROM \'/home/eczerega/dump/csv/labels.txt\';',
	'COPY descriptions FROM \'/home/eczerega/dump/csv/descriptions.txt\';',
	'COPY aliases FROM \'/home/eczerega/dump/csv/aliases.txt\';',
	'COPY claims FROM \'/home/eczerega/dump/csv/claims.txt\';',
	'COPY qualifiers FROM \'/home/eczerega/dump/csv/qualifiers.txt\';',
	'COPY references_table FROM \'/home/eczerega/dump/csv/references.txt\';',
	'COPY references_snak FROM \'/home/eczerega/dump/csv/references_snak.txt\';'
]

errors = File.open("copy_errors.txt", "a")
commands.each |query| do
	begin
		res = conn.exec_params(query)
		puts res
	rescue Exception=> e	
		 copy_errors << e.to_s+'\n'
	end
end