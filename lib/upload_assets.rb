#!/usr/bin/env ruby

require 'yaml'
require 'rest_client'
require 'mime/types'
require 'fileutils'

@username = ''
@password = ''
@host = 'cstaging.nd.edu'

config_file = File.join(File.dirname(__FILE__), "../storage/serializations/transformed-images.yml")
config = YAML.load_file(config_file)
config.each do |key, attributes|
  if (attributes[:conductor] || attributes['conductor']).nil?
    filename = File.join(File.dirname(__FILE__), '../storage/images', (attributes[:temp] || attributes['temp']))
    upload_filename = File.join(File.dirname(__FILE__), '../tmp/', File.basename(filename).sub(/\Acounter-\d+---/,''))
    FileUtils.cp(filename, upload_filename)
    begin
      RestClient.post("https://#{@username}:#{@password}@#{@host}/admin/assets", {"asset" => { "file" => File.new(File.expand_path(upload_filename)), 'tag' => 'imported' }})
    rescue RestClient::Found => e
      uri = URI.parse(e.response.headers[:location])
      attributes[:conductor] = uri
    end
  end
end


File.open(config_file, "w+") do |file|
  file.puts YAML.dump(config)
end
