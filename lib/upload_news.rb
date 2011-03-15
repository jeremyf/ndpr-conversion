#!/usr/bin/env ruby
require 'yaml'
require 'active_support/core_ext/hash'
require 'rest_client'
require 'highline'

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

Dir.glob(File.join(File.dirname(__FILE__), "../storage/serializations/reviews/**/*.yml")).each do |filename|
  attributes = YAML.load_file(filename).stringify_keys
  if attributes['conductor_path'].nil?
    catalog_id = attributes['catalog_id'].to_s.strip
    if catalog_id =~ /\A(\d\d\d\d)\.(\d\d)\.(\d\d)\Z/
      published_at = Time.local($1,$2,$3)
    end
    params = {}
    params['publish'] = '1'
    params['news'] = {}
    params['news']['content'] = attributes['content'].strip
    params['news']['author_id'] = 'other'
    params['news']['title'] = attributes['review_title'].strip
    params['news']['metum_attributes'] = { 'keys' => [], 'data' => []}
    params['news']['published_at'] = published_at
    params['news']['custom_author_name'] = attributes['authors']
    params['news']['metum_attributes']['keys'] << 'edition'
    params['news']['metum_attributes']['data'] << catalog_id
    params['news']['metum_attributes']['keys'] << 'reviewers'
    params['news']['metum_attributes']['data'] << attributes['reviewer']
    params['news']['metum_attributes']['keys'] << 'bibliography'
    params['news']['metum_attributes']['data'] << attributes['bibliography']
    params['news']['metum_attributes']['keys'] << 'authors'
    params['news']['metum_attributes']['data'] << attributes['authors']
    begin
      RestClient.post("#{@protocol}://#{@net_id}:#{@password}@#{@host}/admin/news", params)
    rescue RestClient::Found => e
      uri = URI.parse(e.response.headers[:location])
      path = uri.path
      attributes['conductor_path'] = File.join('/', path)
      File.open(filename, 'w+') do |file|
        file.puts YAML.dump(attributes)
      end
    end
  end
  break
end
