# frozen_string_literal: true

class ScraperService
  CACHE_EXPIRATION = 3600 # 1 hour

  # Default timeout in seconds
  DEFAULT_TIMEOUT = 30

  # Scrapes data from a URL using the provided fields
  # @param url [String] The URL to scrape
  # @param fields [Hash] A hash mapping field names to CSS selectors
  # @param use_browser [Boolean] Whether to use a headless browser for JavaScript rendering
  # @param skip_cache [Boolean] Whether to skip cache and force a fresh scrape
  # @param timeout [Integer] Request timeout in seconds
  # @param headers [Hash] Additional HTTP headers to send with the request
  # @return [Hash] A hash mapping field names to extracted values
  def self.scrape(url:, fields:, use_browser: true, skip_cache: false, timeout: DEFAULT_TIMEOUT, headers: {})
    new(url, fields, use_browser, skip_cache, timeout, headers).scrape
  end

  def initialize(url, fields, use_browser, skip_cache, timeout, headers)
    @url = url
    @fields = fields
    @use_browser = use_browser
    @skip_cache = skip_cache
    @timeout = timeout
    @headers = headers
  end

  def scrape
    UrlValidatorService.validate!(@url)
    @skip_cache ? perform_scrape : scrape_with_cached_response
  end

  private

  def cache_key
    raw_key = "#{@url}-#{@fields.to_json}"
    "scraper:html:#{Digest::SHA256.hexdigest(raw_key)}"
  end

  def scrape_with_cached_response
    Rails.cache.fetch(cache_key, expires_in: CACHE_EXPIRATION) { perform_scrape }
  end

  def perform_scrape
    client = ScraperLib::Client.new(@url, use_browser: @use_browser, timeout: @timeout, headers: @headers)
    client.scrape(@fields)
  end
end
