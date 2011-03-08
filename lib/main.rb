#!/usr/bin/env ruby
# require 'active_record'
require 'yaml'
# require 'set'

module Conversion
  def self.transaction
    yield(self)
  ensure
    dump
  end

  def self.errors
    @registry.collect(&:errors).flatten.compact
  end

  def self.dump
    @registry.each do |register|
      register.dump
    end
  end

  def self.convert!
    @registry.each do |register|
      register.convert!
    end
  end

  def self.register(klass)
    @registry ||= []
    @registry << klass unless @registry.include?(klass)
  end


  class Error < RuntimeError
    def initialize(context, e)
      super("Error:\n\tContext:\n\t\t#{context.inspect}\n\tException:\n\t\t#{e}")
    end
  end

  class Base
    class << self
      def collection_names; ['dictionary', 'errors']; end
      def dictionary
        @dictionary ||= {}
      end

      def errors
        @errors ||= []
      end

      def convert!
        sources.each do |source|
          convert_source!(source)
        end
      end

      def convert_source!(source)
        begin
          create!(source)
        rescue Exception => e
          errors << Error.new(source, e)
        end
      end

      def sources
        (1..5).collect {|i| "#{self.name} ##{i}"}
      end

      def create!(source)
        new(source).tap do |target|
          target.create!
          dictionary[source] = target
        end
      end

      def dump
        collection_names.each do |collection_name|
          File.open("tmp/#{self.name.downcase.gsub(/\W+/,'_')}_#{collection_name}.yml", 'w+') do |file|
            file.puts YAML.dump(send(collection_name))
          end
        end
      end
    end

    attr_reader :source
    def initialize(source)
      @source = source
    end

    def create!
    end
  end
end

class Reviewer < Conversion::Base
end

class Author < Conversion::Base
end

class Review < Conversion::Base
  def create!
    images.each do |image|
      Image.convert_source!(image)
    end
    super
  end

  def images
    (1..5).collect {|i| "#{source} Image ##{i}"}
  end
end

class Image < Conversion::Base
  def self.convert!
    # do nothing
  end
end

Conversion.register Reviewer
Conversion.register Author
Conversion.register Review
Conversion.register Image

Conversion.transaction do |converter|
  converter.convert!
end
