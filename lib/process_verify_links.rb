#!/usr/bin/env ruby
require 'yaml'
require 'hpricot'
require 'open-uri'

['storage/serializations/reviews/review-1017.yml',
'storage/serializations/reviews/review-1072.yml',
'storage/serializations/reviews/review-1089.yml',
'storage/serializations/reviews/review-1105.yml',
'storage/serializations/reviews/review-1149.yml',
'storage/serializations/reviews/review-1175.yml',
"storage/serializations/reviews/review-13030.yml",
"storage/serializations/reviews/review-14509.yml",
"storage/serializations/reviews/review-14685.yml",
"storage/serializations/reviews/review-15027.yml",
"storage/serializations/reviews/review-15648.yml",
"storage/serializations/reviews/review-15889.yml",
"storage/serializations/reviews/review-16705.yml",
"storage/serializations/reviews/review-17005.yml",
"storage/serializations/reviews/review-17145.yml",
"storage/serializations/reviews/review-17347.yml",
"storage/serializations/reviews/review-18106.yml",
"storage/serializations/reviews/review-18148.yml",
"storage/serializations/reviews/review-18166.yml",
"storage/serializations/reviews/review-19067.yml",
"storage/serializations/reviews/review-19307.yml",
"storage/serializations/reviews/review-19447.yml",
"storage/serializations/reviews/review-19507.yml",
"storage/serializations/reviews/review-19827.yml",
"storage/serializations/reviews/review-19890.yml",
"storage/serializations/reviews/review-20167.yml",
"storage/serializations/reviews/review-20807.yml",
"storage/serializations/reviews/review-21029.yml",
"storage/serializations/reviews/review-21470.yml",
"storage/serializations/reviews/review-21629.yml",
"storage/serializations/reviews/review-21729.yml",
"storage/serializations/reviews/review-22149.yml",
"storage/serializations/reviews/review-22609.yml",
"storage/serializations/reviews/review-22749.yml",
"storage/serializations/reviews/review-22890.yml",
"storage/serializations/reviews/review-22949.yml",
"storage/serializations/reviews/review-23211.yml",
"storage/serializations/reviews/review-3721.yml",
"storage/serializations/reviews/review-4641.yml",
"storage/serializations/reviews/review-4761.yml",
"storage/serializations/reviews/review-5481.yml",
"storage/serializations/reviews/review-7044.yml",
"storage/serializations/reviews/review-7063.yml",
"storage/serializations/reviews/review-7083.yml",
"storage/serializations/reviews/review-7163.yml",
"storage/serializations/reviews/review-8344.yml"].each do |filename|
  config = YAML.load_file(filename)
  `open https://#{File.join('ndpr.conductor.nd.edu/admin',config['conductor_path'], 'edit')}`
end
