#!/usr/bin/env ruby

require 'json'
require './translator.rb'

MODE = ARGV[0].to_sym

i_file_name = ARGV[1]
o_file_name = "#{i_file_name.sub(/.json$/,'')}-#{MODE}.nq"

#puts "converting #{i_file_name} -> #{o_file_name}"
#STDOUT.flush

INFILE  = File.new i_file_name, 'r'
OUTFILE = File.new o_file_name, 'w'

@errors = []

translator = Translator.new(MODE, OUTFILE)

while s = INFILE.gets
  s = s.strip.sub(/,$/, '')
  unless s == '[' or s == ']'
    begin
      doc = JSON.parse(s)
      translator.translate(doc)
      OUTFILE << "\n"
    rescue Exception => e
      @errors << {
        'model'           => MODE.to_s,
        'error_message'   => e.inspect,
        'error_backtrace' => e.backtrace.inspect,
        'json_string'     => s
      }
    end
  end
end

if @errors.size > 0
  e_file_name = "#{i_file_name.sub(/.json$/,'')}-#{MODE}-error.json"
  error_file = File.new o_file_name, 'w'
  error_file << @errors.to_json
end
