#!/usr/bin/env ruby

require 'open-uri'
require 'fileutils'

FileUtils.mkdir_p(File.join(File.dirname(__FILE__), "../storage/original"))

# Read through the review ides and write the file.
review_ids_filename = File.join(File.dirname(__FILE__), 'review_ids.txt')
File.open(review_ids_filename, "r") do |infile|
  while (line = infile.gets)
    if line.to_i > 0
      filename = File.join(File.dirname(__FILE__), "../storage/original/review-#{line.to_i}.html")
      if ! File.exist?(filename) || File.size(filename) == 0
        url = "http://ndpr.nd.edu/review.cfm?id=#{line.to_i}"
        puts "Processing: #{url}"
        File.open(filename,'w+') do |outfile|
          outfile.puts open(url).read
        end
      end
    end
  end
end
