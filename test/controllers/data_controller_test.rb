require "test_helper"

class DataControllerTest < ActionDispatch::IntegrationTest
  setup do
    # Clear cache before each test
    Rails.cache.clear
  end
  
  test "should return error when URL is missing" do
    get data_path
    assert_response :bad_request
    
    response_json = JSON.parse(response.body)
    assert_equal "URL parameter is required", response_json.dig("error", "message")
  end
  
  test "should return error when URL is invalid" do
    get data_path, params: { url: "invalid-url" }
    assert_response :bad_request
    
    response_json = JSON.parse(response.body)
    assert_equal "Invalid URL format", response_json.dig("error", "message")
  end
  
  test "should handle scraping with valid URL" do
    # Mock the ScraperService to avoid actual HTTP requests in tests
    mock_result = { "title" => "Test Page" }
    
    ScraperService.stub :scrape, mock_result do
      get data_path, params: { url: "https://example.com" }
      assert_response :success
      
      response_json = JSON.parse(response.body)
      assert_equal "Test Page", response_json["title"]
    end
  end
  
  test "should handle scraping with fields parameter" do
    fields = { "title" => "h1", "paragraphs" => "p" }
    
    # Verify that the service is called with the correct parameters
    ScraperService.stub :scrape, ->(url:, fields:, use_browser:, skip_cache:, timeout:, headers:) {
      assert_equal "https://example.com", url
      assert_equal fields, fields
      assert_equal true, use_browser
      assert_equal false, skip_cache
      assert_nil timeout
      assert_equal({}, headers)
      { "title" => "Test Page", "paragraphs" => ["P1", "P2"] }
    } do
      get data_path, params: { url: "https://example.com", fields: fields }
      assert_response :success
      
      response_json = JSON.parse(response.body)
      assert_equal "Test Page", response_json["title"]
      assert_equal ["P1", "P2"], response_json["paragraphs"]
    end
  end
  
  test "should respect use_browser parameter" do
    ScraperService.stub :scrape, ->(url:, fields:, use_browser:, skip_cache:, timeout:, headers:) {
      assert_equal false, use_browser
      { "result" => "success" }
    } do
      get data_path, params: { url: "https://example.com", use_browser: "false" }
      assert_response :success
    end
  end
  
  test "should respect skip_cache parameter" do
    ScraperService.stub :scrape, ->(url:, fields:, use_browser:, skip_cache:, timeout:, headers:) {
      assert_equal true, skip_cache
      { "result" => "success" }
    } do
      get data_path, params: { url: "https://example.com", skip_cache: "true" }
      assert_response :success
    end
  end
  
  test "should respect timeout parameter" do
    ScraperService.stub :scrape, ->(url:, fields:, use_browser:, skip_cache:, timeout:, headers:) {
      assert_equal 60, timeout
      { "result" => "success" }
    } do
      get data_path, params: { url: "https://example.com", timeout: "60" }
      assert_response :success
    end
  end
  
  test "should respect headers parameter" do
    custom_headers = { "User-Agent" => "Custom Agent" }
    
    ScraperService.stub :scrape, ->(url:, fields:, use_browser:, skip_cache:, timeout:, headers:) {
      assert_equal custom_headers, headers
      { "result" => "success" }
    } do
      get data_path, params: { 
        url: "https://example.com", 
        headers: custom_headers.to_json
      }
      assert_response :success
    end
  end
  
  test "should handle invalid headers JSON" do
    ScraperService.stub :scrape, ->(url:, fields:, use_browser:, skip_cache:, timeout:, headers:) {
      assert_equal({}, headers)
      { "result" => "success" }
    } do
      get data_path, params: { 
        url: "https://example.com", 
        headers: "invalid-json"
      }
      assert_response :success
    end
  end
  
  test "should handle service unavailable errors" do
    ScraperService.stub :scrape, ->(*) { raise ScraperLib::FetchError, "Service unavailable" } do
      get data_path, params: { url: "https://example.com" }
      assert_response :service_unavailable
      
      response_json = JSON.parse(response.body)
      assert_equal "Service unavailable", response_json.dig("error", "message")
    end
  end
  
  test "should handle parsing errors" do
    ScraperService.stub :scrape, ->(*) { raise ScraperLib::ParseError, "Failed to parse HTML" } do
      get data_path, params: { url: "https://example.com" }
      assert_response :unprocessable_entity
      
      response_json = JSON.parse(response.body)
      assert_equal "Failed to parse HTML", response_json.dig("error", "message")
    end
  end
  
  test "should handle unexpected errors" do
    ScraperService.stub :scrape, ->(*) { raise StandardError, "Unexpected error" } do
      get data_path, params: { url: "https://example.com" }
      assert_response :internal_server_error
      
      response_json = JSON.parse(response.body)
      assert_equal "An unexpected error occurred while processing your request", response_json.dig("error", "message")
    end
  end
end