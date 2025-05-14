# frozen_string_literal: true

class UrlValidatorService
  class InvalidUrlError < StandardError; end

  # Validates a URL and raises an error if it's invalid
  # @param url [String] The URL to validate
  # @raise [InvalidUrlError] If the URL is blank or invalid
  def self.validate!(url)
    new(url).validate!
  end

  def initialize(url)
    @url = url
  end

  def validate!
    raise InvalidUrlError, "URL parameter is required" if @url.blank?
    
    uri = URI.parse(@url)
    unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)
      raise InvalidUrlError, "Invalid URL format"
    end
    
    true
  rescue URI::InvalidURIError
    raise InvalidUrlError, "Invalid URL format"
  end
end