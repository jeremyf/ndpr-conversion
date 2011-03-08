#!/usr/bin/env ruby
require 'hpricot'
require 'yaml'

exceptions = []
Dir.glob(File.join(File.dirname(__FILE__), '../src/html/*.html')).each do |filename|
  begin
    # filename = "/Users/jeremyf/Documents/Repositories/git/ndpr-conversion/lib/../src/review-2521.html"
    dictionary = {}
    review_id = File.basename(filename).gsub(/review-(\d*)\.html/,'\1')
    if File.size(filename) > 0
      doc = open(filename) { |file| Hpricot(file) }

      doc.search("#content #review").each do |content|
        original_html = content.to_original_html.sub("<div id=\"review\">", '')[0..-7]
        dictionary['review_id']    = review_id.strip.to_i
        [
          ['catalog_id', 'h1'],
          ['authors', 'h4'],
          ['review_title', 'h2'],
          ['bibliography', 'p.biblio'],
          ['reviewer', 'p strong'],
        ].each do |key, selector|
          node = (content/"#{selector}:first-of-type")
          dictionary[key] = node[0].inner_html.strip
          if key == 'reviewer'
            node[0].search("/..p").each { |n| original_html.sub!(n.to_original_html,'') }
          else
            original_html.sub!(node[0].to_original_html,'')
          end
        end
        (content/"div#hr:first-of-type").each {|n| original_html.sub!(n.to_original_html, '')}

        # dictionary['catalog_id']   = node.inner_html.strip
        # dictionary['authors']      = (content/"h4").first.inner_html.strip
        # dictionary['review_title'] = (content/"h2").first.inner_html.strip
        # dictionary['bibliography'] = (content/"p.biblio").first.inner_html.strip
        # dictionary['reviewer']     = (content/"p strong").first.inner_html.strip
        # review_content = (content/"div#hr").first.following_siblings.collect{|sib| sib.to_original_html}.join("\n")
        dictionary['content']      = original_html #review_content #.sub(/ *\<\/div\> *\<\/div\>$/,'')
      end
      File.open(File.join(File.dirname(__FILE__), "../src/yml/review-#{review_id}.yml"), 'w+') do |file|
        file.puts YAML.dump(dictionary)
      end
    end
  rescue RuntimeError => e
    exceptions << [filename, e]
  end
end

puts "Errors: #{exceptions.inspect}"
