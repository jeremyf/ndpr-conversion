#!/usr/bin/env ruby

require 'open-uri'

review_ids_filename = File.join(File.dirname(__FILE__), '../src/review_ids.txt')
File.open(review_ids_filename, "r") do |infile|
  while (line = infile.gets)
    if line.to_i > 0
      filename = File.join(File.dirname(__FILE__), "../src/html/review-#{line.to_i}.html")
      if ! File.exist?(filename) || File.size(filename) == 0
        url = "http://ndpr.nd.edu/review.cfm?id=#{line.to_i}"
        puts "Processing: #{url}"
        File.open(File.join(File.dirname(__FILE__), "../src/review-#{line.to_i}.html"),'w+') do |outfile|
          outfile.puts open(url).read
        end
      end
    end
  end
end