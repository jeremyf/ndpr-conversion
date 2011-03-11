#!/usr/bin/env ruby
require 'hpricot'
require 'yaml'
require 'logger'
log     = Logger.new(File.join(File.dirname(__FILE__), '../tmp/parse_source.log'), 5, 10*1024)

@exceptions = []
@images = Set.new
@links = Set.new
log.info "\n"
log.info "=" * 80
log.info "=" * 80
log.info "\n"
log.info "Parsing HTML File"
log.info "\n"
log.info "=" * 80
log.info "\n"

def look_for_images(content, dictionary = {})
  dictionary['images'] ||= []
  (content/"img").each do |image|
    src = image.get_attribute('src')
    if src.to_s.strip =~ /^\#/
      dictionary['images'] << src
      @images << src
    end
  end
end

def look_for_links(content, dictionary = {})
  dictionary['links'] ||= []
  (content/"a").each do |image|
    href = image.get_attribute('href')
    unless href.to_s.strip == ''
      dictionary['links'] << href
      @links << href
    end
  end
end

Dir.glob(File.join(File.dirname(__FILE__), '../src/html/*.html')).each do |filename|
  begin
    log.info
    # filename = "/Users/jeremyf/Documents/Repositories/git/ndpr-conversion/lib/../src/review-2521.html"
    dictionary = {}
    review_id = File.basename(filename).gsub(/review-(\d*)\.html/,'\1')
    log.info "\tBegin processing review ID: #{review_id}"

    if File.size(filename) > 0
      doc = open(filename) { |file| Hpricot(file) }

      doc.search("#content #review").each do |content|
        dictionary['review_id']    = review_id.strip.to_i

        look_for_images(content, dictionary)
        look_for_links(content, dictionary)

        original_html = content.to_original_html.sub("<div id=\"review\">", '')[0..-7]
        [
          ['catalog_id', 'h1', nil],
          ['authors', 'h4', nil],
          ['review_title', 'h2', nil],
          ['bibliography', 'p.biblio', nil],
          ['reviewer', 'p strong', /\A *Reviewed by(.*)\Z/],
        ].each do |key, selector, regex|
          node = (content/"#{selector}:first-of-type")
          dictionary[key] = node[0].inner_html.strip
          if key == 'reviewer'
            node[0].search("/..p").each { |n| original_html.sub!(n.to_original_html,'') }
          else
            original_html.sub!(node[0].to_original_html,'')
          end
          if regex
            dictionary[key] = dictionary[key].sub(regex, '\1').strip
          end
        end
        (content/"div#hr:first-of-type").each {|n| original_html.sub!(n.to_original_html, '')}

        log.info "\t\tCatalog ID: #{dictionary['catalog-id']}"
        log.info "\t\tAuthors: #{dictionary['author']}"
        log.info "\t\tReview Title: #{dictionary['review_title']}"
        log.info "\t\tBibliography: #{dictionary['bibliography']}"
        log.info "\t\tReviewer: #{dictionary['reviewer']}"
        log.info "\t\tImages: #{dictionary['images'].join(', ')}"
        log.info "\t\tLinks: #{dictionary['links'].join(', ')}"

        # dictionary['catalog_id']   = node.inner_html.strip
        # dictionary['authors']      = (content/"h4").first.inner_html.strip
        # dictionary['review_title'] = (content/"h2").first.inner_html.strip
        # dictionary['bibliography'] = (content/"p.biblio").first.inner_html.strip
        # dictionary['reviewer']     = (content/"p strong").first.inner_html.strip
        # review_content = (content/"div#hr").first.following_siblings.collect{|sib| sib.to_original_html}.join("\n")
        dictionary['content']      = original_html.strip
      end
      File.open(File.join(File.dirname(__FILE__), "../src/yml/review-#{review_id}.yml"), 'w+') do |file|
        file.puts YAML.dump(dictionary)
      end
      log.info "\tEnd processing review ID: #{review_id}"
    end
  rescue RuntimeError => e
    @exceptions << [filename, e]
  end
end

File.open(File.join(File.dirname(__FILE__), "../src/transformations/source-images.yml"), 'w+') do |file|
  file.puts YAML.dump(@images.to_a)
end

File.open(File.join(File.dirname(__FILE__), "../src/transformations/source-links.yml"), 'w+') do |file|
  file.puts YAML.dump(@links.to_a)
end


log.info "\tExceptions"
@exceptions.each do |exception|
  log.info "\t\t#{exception}"
end
log.info "\n"
log.info "=" * 80
log.info "\n"
log.info "End Parsing HTML File"
log.info "\n"
log.info "=" * 80
log.info "=" * 80
log.info "\n"
