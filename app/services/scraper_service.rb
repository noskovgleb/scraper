# frozen_string_literal: true

class ScraperService
  # Scrapes data from a URL using the provided fields
  # @param url [String] The URL to scrape
  # @param fields [Hash] A hash mapping field names to CSS selectors
  # @param use_browser [Boolean] Whether to use a headless browser for JavaScript rendering
  # @return [Hash] A hash mapping field names to extracted values
  def self.scrape(url:, fields:, use_browser: true)
    new(url, fields, use_browser).scrape
  end

  def initialize(url, fields, use_browser)
    @url = url
    @fields = fields
    @use_browser = use_browser
  end

  def scrape
    UrlValidatorService.validate!(@url)
    client = ScraperLib::Client.new(@url, use_browser: @use_browser)
    client.scrape(@fields)
  end
end