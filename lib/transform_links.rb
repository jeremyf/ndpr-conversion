#!/usr/bin/env ruby
require 'yaml'
require 'open-uri'
require 'fileutils'


link_filename = File.join(File.dirname(__FILE__), "../storage/serializations/source-links.yml")
image_filename = File.join(File.dirname(__FILE__), "../storage/serializations/source-images.yml")

@source_links = YAML.load_file(link_filename)
@source_images = YAML.load_file(image_filename)

@images_counter = 0

# Copy all existing images locally for upload and transformation

FileUtils.mkdir_p(File.join(File.dirname(__FILE__), "../storage/images")) unless File.exist?(File.join(File.dirname(__FILE__), "../storage/images"))

@images = @source_images.inject({}) do |mem, from|
  source = (from =~ /^\// ? File.join('http://ndpr.nd.edu', from) : from)
  begin
    handle = open(source)
    base_filename = File.basename(from)
    @images_counter += 1
    output_filename = File.join(File.dirname(__FILE__), "../storage/images/counter-#{@images_counter}---#{base_filename}")
    File.open(output_filename, 'w+') do |file|
      file.puts handle.read
    end
    mem[from] = {:temp => File.basename(output_filename), :conductor => nil}
  rescue SocketError => e
    puts "#{e} for image src='#{from}'"
  rescue OpenURI::HTTPError => e
    puts "#{e} for image src='#{from}'"
  rescue Errno::ENOENT => e
    puts "Cannot process image src='#{from}'"
  end
  mem
end

output_image_filename = File.join(File.dirname(__FILE__), "../storage/serializations/transformed-images.yml")
File.open(output_image_filename, 'w+') do |file|
  file.puts YAML.dump(@images)
end

# Process all source links
@links = @source_links.inject({}) do |mem, from|
  pairing = {:source => from}
  case from
  when /\Afile\:\//i then
    if from =~ (/\A[^\#]*(\#.*)\Z/)
      pairing[:target] = $1
    end
  when /\A\#/ then
    pairing[:target] = from
  when /\#(.*)\Z/
    pairing[:target] = "##{$1}"
  when /\A(\.\.)?\//
    puts from
    require 'ruby-debug'; debugger; true;
    pairing[:target] = from
  when /\Ahttps?:\/\/(cfweb-prod|ndpr)\.nd\.edu/
    puts from
    require 'ruby-debug'; debugger; true;
    pairing[:target] = from
  when /\Ahttps?:\/\/ndpr\.icaap\.org/
    puts from
    require 'ruby-debug'; debugger; true;
    pairing[:target] = from
  else
    puts from
    require 'ruby-debug'; debugger; true;
    pairing[:target] = from
  end
  mem[from] = pairing
  mem
end

output_links_filename = File.join(File.dirname(__FILE__), "../storage/serializations/transformed-links.yml")
File.open(output_links_filename, 'w+') do |file|
  file.puts YAML.dump(@links)
end