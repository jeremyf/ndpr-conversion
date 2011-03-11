#!/usr/bin/env ruby
require 'yaml'
require 'rest_client'
@username = ''
@password = ''
@host = 'cstaging.nd.edu'

Dir.glob(File.join(File.dirname(__FILE__), "../storage/serializations/reviews/**/*.yml")).each do |filename|
  attributes = YAML.load_file(filename)
  begin
    RestClient.post("https://#{@username}:#{@password}@#{@host}/admin/news", {"news" => { 'content' => attributes['content']})
  rescue RestClient::Found => e
    uri = URI.parse(e.response.headers[:location])
    path = uri.path.sub(/\/admin\/assets\//)
    attributes[:conductor_path] = File.join('/', path, File.basename(upload_filename))
  end
end