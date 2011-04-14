#!/usr/bin/env ruby
require 'yaml'
require 'uri'

Dir.glob(File.join(File.dirname(__FILE__), "../storage/serializations/reviews/**/*.yml")).each do |filename|
  file_info = YAML.load_file(filename)
  if file_info['content'].grep(/[A-Z]/).none?
    require 'ruby-debug'; debugger; true;
  end
end
