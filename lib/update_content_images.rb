#!/usr/bin/env ruby
require 'yaml'
require 'uri'

asset_transformation_config = YAML.load_file(File.join(File.dirname(__FILE__), "../storage/serializations/transformed-images.yml"))

Dir.glob(File.join(File.dirname(__FILE__), "../storage/serializations/reviews/**/*.yml")).each do |filename|
  file_info = YAML.load_file(filename)
  file_info['images'].each do |image_path|
    if target_config = asset_transformation_config[image_path]
      if path = (target_config[:conductor_path] || target_config['conductor_path'])
        file_info['transformed_content'] ||= file_info['content']
        file_info['transformed_content'].gsub!(/(["|'])#{image_path}(["|'])/, '\1' << path << '\2')
      end
    end
  end
  if file_info['transformed_content']
    File.open(filename, 'w+') do |file|
      file.puts YAML.dump(file_info)
    end
  end
end
