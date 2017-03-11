#!/usr/bin/env ruby
require './scraper_factory'

def write_to_file(filename, content)
  File.open(filename, 'w') do |f|
    f.puts content
  end
end

raise 'Top unspecified' if ARGV[0] == ''
raise 'No speciffied file' if ARGV[1] == ''
scraper = ScraperFactory.get_scraper(ARGV[0])
raise 'Invalid top' if scraper.nil?
write_to_file(ARGV[1], scraper.parse_content)
