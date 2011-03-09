#!/usr/bin/env ruby

require 'erb'
require 'yaml'

Dir.glob(File.join(File.dirname(__FILE__), "../src/yml/*.yml")).each do |filename|
  object = YAML.load_file(filename)
  buffer = ERB.new(File.read(File.join(File.dirname(__FILE__), '../src/template.erb.html'))).result(binding)
  target_filename = File.join(File.dirname(__FILE__), "../src/output/review-#{object['review_id']}.html")
  source_filename = File.join(File.dirname(__FILE__), "../src/html/review-#{object['review_id']}.html")
  File.open(target_filename, 'w+') do |file|
    file.puts buffer
  end
  regexp_for_split = /./
  target = buffer.split(regexp_for_split).join("\n")
  source = File.read(source_filename).split(regexp_for_split).join("\n")

  begin
    tmp_target_filename = File.join(File.dirname(__FILE__), "../tmp/target-#{object['review_id']}.html")
    tmp_source_filename = File.join(File.dirname(__FILE__), "../tmp/source-#{object['review_id']}.html")
    File.open(tmp_source_filename, 'w+') { |file| file.puts source }

    File.open(tmp_target_filename, 'w+') { |file| file.puts target }

    diff = `diff #{tmp_source_filename} #{tmp_target_filename} -EwBb`.strip
    if diff.any?
      require 'ruby-debug'; debugger; true;
      puts "Review differences for Review #{object['review_id']}:\n\n#{diff}\n\n#{diff.inspect}"
    end
  ensure
    File.unlink(tmp_target_filename) if File.exist?(tmp_target_filename)
    File.unlink(tmp_source_filename) if File.exist?(tmp_source_filename)
  end
end
