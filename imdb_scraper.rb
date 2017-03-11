require 'nokogiri'
require 'pry'
require 'json'
require 'httparty'
require './movie'
require './scraper'

class IMDBScraper < Scraper
  def self.instance
    @object.nil? ? new : @object
  end

  def parse_content
    content = []
    links.each do |link|
      page = Nokogiri::HTML(HTTParty.get(link))
      movie = Movie.new
      section = page.css('#main_top')
      process_upper(page, movie, section.css('.vital'))
      process_lower(page, movie, page.css('.plot_summary'))
      content.push(movie.to_json)
      puts movie.name
    end
    JSON.pretty_generate(content)
  end

  private

  def new
    @object = IMDBScraper.new
  end

  def array_of(part, name)
    tag_list = part.css('.credit_summary_item').css("span[itemprop='#{name}']")
    result = []
    tag_list.each { |item| result.push(item.css('a').css('span').text) }
    result
  end

  def process_upper(page, movie, upper)
    movie.picture = page.css('.poster').css('a').css('img').last.attributes['src'].value
    movie.year = upper.css('.title_wrapper').css('h1').css('#titleYear').first.children.children.text
    movie.name = upper.css('.title_wrapper').css('h1').children.first.text
  end

  def process_lower(page, movie, lower)
    movie.rating = page.css("span[itemprop='ratingValue']").text
    movie.description = lower.css('.summary_text').children.text.strip
    movie.director = array_of(lower, 'director')
    movie.writer = array_of(lower, 'creator')
    movie.actor = array_of(lower, 'actors')
  end

  def movie_name(wrapper)
    wrapper.css('.titleColumn').css('a')[0].attributes.first[1].value
  end

  def links
    links = []
    sitename = 'http://www.imdb.com'
    page = Nokogiri::HTML(HTTParty.get('http://www.imdb.com/chart/top'))
    items = page.css('.lister-list').css('tr')
    items.each { |item| links << sitename + movie_name(item) }
    links
  end
end
