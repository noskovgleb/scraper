require "test_helper"

class DataControllerTest < ActionDispatch::IntegrationTest
  test "should return error when URL is missing" do
    get data_path
    assert_response :bad_request
    
    response_json = JSON.parse(response.body)
    assert_equal "URL parameter is required", response_json["error"]
  end
  
  test "should return error when URL is invalid" do
    get data_path, params: { url: "invalid-url" }
    assert_response :bad_request
    
    response_json = JSON.parse(response.body)
    assert_equal "Invalid URL format", response_json["error"]
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
    ScraperService.stub :scrape, ->(url:, fields:, use_browser:) {
      assert_equal "https://example.com", url
      assert_equal fields, fields
      assert_equal true, use_browser
      { "title" => "Test Page", "paragraphs" => ["P1", "P2"] }
    } do
      get data_path, params: { url: "https://example.com", fields: fields }
      assert_response :success
      
      response_json = JSON.parse(response.body)
      assert_equal "Test Page", response_json["title"]
      assert_equal ["P1", "P2"], response_json["paragraphs"]
    end
  end
  
  test "should handle service unavailable errors" do
    ScraperService.stub :scrape, ->(*) { raise ScraperLib::FetchError, "Service unavailable" } do
      get data_path, params: { url: "https://example.com" }
      assert_response :service_unavailable
      
      response_json = JSON.parse(response.body)
      assert_equal "Service unavailable", response_json["error"]
    end
  end
  
  test "should handle unexpected errors" do
    ScraperService.stub :scrape, ->(*) { raise StandardError, "Unexpected error" } do
      get data_path, params: { url: "https://example.com" }
      assert_response :internal_server_error
      
      response_json = JSON.parse(response.body)
      assert_equal "An unexpected error occurred while processing your request", response_json["error"]
    end
  end
end