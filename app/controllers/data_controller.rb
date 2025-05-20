class DataController < ApplicationController
  before_action :validate_url_presence

  # GET /data
  # Scrapes data from a URL using the provided fields
  def index
    result = ScraperService.scrape(
      url: params[:url],
      fields: fields_params,
      use_browser: browser_param,
      skip_cache: skip_cache_param,
      timeout: timeout_param,
      headers: headers_param
    )

    render json: result
  rescue UrlValidatorService::InvalidUrlError => e
    render_error(e.message, :bad_request)
  rescue ScraperLib::FetchError => e
    render_error(e.message, :service_unavailable)
  rescue ScraperLib::ParseError => e
    render_error(e.message, :unprocessable_entity)
  rescue StandardError => e
    Rails.logger.error("Scraping error: #{e.message}\n#{e.backtrace.join("\n")}")
    render_error("An unexpected error occurred while processing your request", :internal_server_error)
  end

  private

  def validate_url_presence
    render_error("URL parameter is required", :bad_request) unless params[:url].present?
  end

  def fields_params
    params.permit(:url, fields: {})[:fields].to_h
  end

  # Determine if browser should be used for rendering
  # Default is true unless explicitly set to false
  def browser_param
    return true unless params.key?(:use_browser)
    params[:use_browser].to_s.downcase != "false"
  end

  # Determine if cache should be skipped
  # Default is false unless explicitly set to true
  def skip_cache_param
    params[:skip_cache].to_s.downcase == "true"
  end

  # Get timeout parameter (in seconds)
  # Default is nil (use service default)
  def timeout_param
    params[:timeout].present? ? params[:timeout].to_i : nil
  end

  # Get custom headers from parameters
  # Headers should be passed as a JSON object in the headers parameter
  def headers_param
    return {} unless params[:headers].present?

    begin
      headers = JSON.parse(params[:headers])
      headers.is_a?(Hash) ? headers : {}
    rescue JSON::ParserError
      Rails.logger.warn("Invalid JSON in headers parameter: #{params[:headers]}")
      {}
    end
  end
end
