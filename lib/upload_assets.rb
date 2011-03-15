#!/usr/bin/env ruby

require 'yaml'
require 'rest_client'
require 'fileutils'

@highline = HighLine.new

def net_id
  @net_id ||= @highline.ask(@highline.color("Net ID: ", :black, :on_yellow))
end

def password
  @password ||= @highline.ask(@highline.color("Password: ", :black, :on_yellow)) { |q| q.echo = "*" }
end
net_id
password
@host = 'localhost:3000'
@protocol = 'http'

config_file = File.join(File.dirname(__FILE__), "../storage/serializations/transformed-images.yml")
config = YAML.load_file(config_file)
config.each do |key, attributes|
  if (attributes[:conductor] || attributes['conductor']).nil?
    filename = File.join(File.dirname(__FILE__), '../storage/images', (attributes[:temp] || attributes['temp']))
    upload_filename = File.join(File.dirname(__FILE__), '../tmp/', File.basename(filename).sub(/\Acounter-\d+---/,''))
    FileUtils.cp(filename, upload_filename)
    begin
      RestClient.post("#{@protocol}://#{@net_id}:#{@password}@#{@host}/admin/assets", {"asset" => { "file" => File.new(File.expand_path(upload_filename)), 'tag' => 'imported' }})
    rescue RestClient::Found => e
      uri = URI.parse(e.response.headers[:location])
      path = uri.path.sub(/\/admin\/assets\//)
      attributes[:conductor_path] = File.join('/', path, File.basename(upload_filename))
    end
  end
end

# Lets write down where things went
File.open(config_file, "w+") do |file|
  file.puts YAML.dump(config)
end
