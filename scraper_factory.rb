require './imdb_scraper'
class ScraperFactory
  def self.get_scraper(scraper_type)
    case scraper_type.downcase
    when 'imdb'
      IMDBScraper.instance
    else
      nil
    end
  end
end
