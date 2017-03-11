require 'nokogiri'
require 'pry'
require 'json'
require 'httparty'

def array_of(part, name)
  tag_list = part.css('.credit_summary_item').css("span[itemprop='#{name}']")
  result = []
  tag_list.each { |item| result.push(item.css('a').css('span').text) }
  result
end

def write_to_file(filename, content)
  File.open(filename, 'w') do |f|
    f.puts content
  end
end

def get_conten(links)
  content = Array.new()
  index = 0
  links.each do |link|
    movie = Hash.new()
    page = Nokogiri::HTML(HTTParty.get(link))
    index += 1;
    section = page.css("#main_top")
    upperPart = section.css(".vital")
    movie[:picture] = page.css(".poster").css("a").css("img").last.attributes["src"].value
    movie[:year] = upperPart.css(".title_wrapper").css("h1").css("#titleYear").first.children.children.text
    movie[:name] = upperPart.css(".title_wrapper").css("h1").children.first.text
    puts "#{movie[:name]}(#{index}/#{links.length})"
    lowerPart = page.css(".plot_summary")
    movie[:rating] = page.css("span[itemprop='ratingValue']").text
    movie[:description] = lowerPart.css(".summary_text").children.text.strip
    movie[:director] = arrayOf(lowerPart,'director')
    movie[:writer] = arrayOf(lowerPart, 'creator')
    movie[:actor] = arrayOf(lowerPart, 'actors')
    content.push(movie)
    sleep(1)
  end
  return JSON.pretty_generate(content)
end

def links
  links = []
  sitename = 'http://www.imdb.com'
  page = Nokogiri::HTML(HTTParty.get("http://www.imdb.com/chart/top"))
  items = page.css(".lister-list").css("tr")
  items.each { |item| links<<sitename + item.css(".titleColumn").css("a")[0].attributes.first[1].value }
  return links
end

data = getContent(links)
writeToFile("movies.json",data)
