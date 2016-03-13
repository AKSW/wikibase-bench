require 'yaml'
require 'erb'
require 'net/http'

include ERB::Util

class QueryRunner
  attr_reader :queries

  def initialize(endpoint, directory, options={})
    @endpoint = endpoint
    @directory = directory
    @timeout = options[:timeout] || 300
    @queries = {}

    Dir[File.join(@directory, '*.sparql')].sort.each do |file|
      query = ''
      File.new(file).each_line do |line|
        query << line unless /^#/ === line
      end
    
      if query.strip != ''
        @queries[File.basename(file).gsub(/\.sparql$/,'')] = {
          code: url_encode(query),
          results: []
        }
      end
    end

    @http = Net::HTTP.new(URI.parse(@endpoint).host, URI.parse(@endpoint).port)
    @http.open_timeout = 60
    @http.read_timeout = @timeout.to_i
  end

  def run(name)
    if @queries[name]
      url = "#{@endpoint}?query=#{@queries[name][:code]}"
  
      begin
        t1 = Time.now
        resp = @http.get(URI(url))
        t2 = Time.now
        result = {time: t2-t1, body: resp.body, status: resp.code}
      rescue RuntimeError => e
        result = {time: 'timeout'}
      end
    
      @queries[name][:results] << result
    end
    STDERR.puts result.inspect
    result
  end

end

