#!/usr/bin/env ruby
require 'yaml'
require 'active_support/core_ext/hash'
require 'active_support/time'
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
@host = 'ndpr.conductor.nd.edu'
@protocol = 'https'

def parse_time(year, month, dayish)
  begin
    if new_time = Time.local(year.to_i, month.to_i, dayish.to_i, 2, 0, dayish.to_i)
      if new_time.month != month.to_i
        2.hours.from_now(Time.local(year.to_i, month.to_i, 1).end_of_month.beginning_of_day + dayish.to_i)
      else
        return new_time
      end
    end
  rescue ArgumentError => e
    return 2.hours.from_now(Time.local(year.to_i, month.to_i, 1).end_of_month.beginning_of_day + dayish.to_i)
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "../storage/serializations/reviews/**/*.yml")).each do |filename|
  begin
    @retry = true
    attributes = YAML.load_file(filename).stringify_keys
    if attributes['conductor_path'].nil?
      catalog_id = attributes['catalog_id'].to_s.strip
      edition_number = nil
      if catalog_id =~ /\A(\d\d\d\d)\.(\d\d)\.(\d\d\w?)\Z/
        edition_number = $3
        published_at = parse_time($1.to_i,$2.to_i,$3.to_i)
      end
      params = {}
      params['without_expire'] = '1'
      params['publish'] = '1'
      params['news'] = {}
      params['news']['content'] = (attributes['transformed_content'] || attributes['content']).strip
      params['news']['author_id'] = 'other'
      params['news']['title'] = attributes['review_title'].strip
      params['news']['metum_attributes'] = { 'keys' => [], 'data' => []}
      params['news']['published_at'] = published_at
      params['news']['custom_author_name'] = attributes['authors']
      params['news']['metum_attributes']['keys'] << 'edition'
      params['news']['metum_attributes']['data'] << edition_number
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
        attributes['conductor_path'] = File.join('/', path).sub("/admin/", '/')
        puts "Uploaded #{catalog_id} to #{attributes['conductor_path']}"
        File.open(filename, 'w+') do |file|
          file.puts YAML.dump(attributes)
        end
      end
    end
  rescue Exception => e
    if @retry == true
      sleep(5)
      @retry = false
      retry
    else
      require 'ruby-debug'; debugger; true;
    end
  end
end
