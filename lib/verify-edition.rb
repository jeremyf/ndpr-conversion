require 'ruby-debug'
require 'hpricot'
require 'yaml'
require 'logger'
require 'fileutils'
require 'open-uri'
require 'rest-client'


review_ids_filename = File.join(File.dirname(__FILE__), '../storage/redirect.ndpr.txt')

File.open(review_ids_filename, "r") do |infile|
  while (line = infile.gets)
    if line =~ /^http/
      begin
        original_url, migrated_url = line.chomp.split(/ +/)
        migrated_url.gsub!(/:\/\//, '://conductor:preview@')
        original_edition = nil
        migrated_edition = nil

        response = RestClient.get(original_url)
        doc = Hpricot(response.body)
        original_edition = doc.search("#content h1:first").inner_html.to_s.strip

        migrated_response = RestClient.get(migrated_url)
        migrated_doc = Hpricot(migrated_response.body)
        migrated_edition = migrated_doc.search("#content h1:first").inner_html.to_s.strip

        if migrated_edition != original_edition
          puts "ERROR #{original_edition}\n\tOriginal #{original_url}\n\tMigrated to #{migrated_url}\n\tOriginal Edition: #{original_edition}\n\tNew Edition: #{migrated_edition}"
        else
          puts "PASS #{original_edition}"
        end
      rescue NoMethodError => e
        # we have a parse error
        require 'ruby-debug'; debugger; true;
      end
    end
  end
end
