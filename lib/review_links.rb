#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'rest_client'
require 'open-uri'
require 'highline'
require 'hpricot'

@highline = HighLine.new

def conductor_username
  @conductor_username ||= @highline.ask(@highline.color("Conductor Username: ", :black, :on_yellow))
end

def conductor_password
  @conductor_password ||= @highline.ask(@highline.color("Conductor Password: ", :black, :on_yellow)) { |q| q.echo = "*" }
end

conductor_username
conductor_password

@host = 'ndpr.conductor.nd.edu'
@protocol = 'https'

@links = Set.new
@images = Set.new

def visit_each_link(content, doc, object)
  (content/"a").each do |link|
    href = link.get_attribute('href')
    case href.to_s.strip
    when ''   then nil
    when /^#/ then
      if doc.search("a[@name='#{href.sub(/^#/,'')}']").count < 1
        @links << [object['conductor_path'], href]
      end
    when /^http/ then
      begin
        open(href)
      rescue SocketError => e
        @links << [object['conductor_path'], href]
      rescue Exception => e
        @links << [object['conductor_path'], href]
      end
    when '**VERIFY**'
      @links << [object['conductor_path'], link.html]
    end
  end
end

def visit_each_image(content, doc, object)
  (content/'img').each do |image|
    src = image.get_attribute('src')
    begin
      case src.to_s.strip
      when /^\//
        RestClient.get("#{@protocol}://#{@conductor_username}:#{@conductor_password}@#{File.join(@host, src)}")
      else
        open(src)
      end
    rescue Errno::ENOENT => e
      @images << [object['conductor_path'], image.get_attribute('src'), e.to_s]
    rescue SocketError => e
      @images << [object['conductor_path'], image.get_attribute('src'), e.to_s]
    rescue RuntimeError => e
      @images << [object['conductor_path'], image.get_attribute('src'), e.to_s]
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), "../storage/serializations/reviews/*.yml")).each do |filename|
  object = YAML.load_file(filename)
  url = "#{@protocol}://#{@conductor_username}:#{@conductor_password}@#{File.join(@host, object['conductor_path'])}"
  begin
    response = RestClient.get(url)
  rescue Exception => e
    require 'ruby-debug'; debugger; true;
  end

  doc = Hpricot(response.body)

  doc.search('#content div.entry-content').each do |content|
    visit_each_link(content, doc, object)
    visit_each_image(content, doc, object)
  end
end

require 'ruby-debug'; debugger; true;