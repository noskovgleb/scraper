class DataController < ApplicationController
  # GET /data
  # Scrapes data from a URL using the provided fields
  def index
    result = ScraperService.scrape(
      url: params[:url],
      fields: fields_params,
      use_browser: true
    )
    
    render json: result
  rescue UrlValidatorService::InvalidUrlError => e
    render json: { error: e.message }, status: :bad_request
  rescue ScraperLib::FetchError => e
    render json: { error: e.message }, status: :service_unavailable
  rescue StandardError => e
    Rails.logger.error("Scraping error: #{e.message}\n#{e.backtrace.join("\n")}")
    render json: { error: "An unexpected error occurred while processing your request" }, status: :internal_server_error
  end

  private

  def fields_params
    params.permit(:url, fields: {})[:fields].to_h
  end
end
