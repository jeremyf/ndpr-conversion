#!/usr/bin/env ruby
require 'yaml'
require 'active_support/core_ext/hash'

File.open(File.join(File.dirname(__FILE__), '../storage/redirect.ndpr.txt'), 'w+') do |redirect_file|
  redirect_file.puts(%(##))
  redirect_file.puts(%(## This file is present to provide mappings for NDPR reviews that))
  redirect_file.puts(%(## were created prior to the move to Conductor))
  redirect_file.puts(%(##))
  redirect_file.puts(%())
  Dir.glob(File.join(File.dirname(__FILE__), "../storage/serializations/reviews/**/*.yml")).each do |filename|
    attributes = YAML.load_file(filename).stringify_keys
    redirect_file.puts(%(id=#{attributes['review_id']}\t#{attributes['conductor_path'].sub("/admin/", '/')}))
  end
end