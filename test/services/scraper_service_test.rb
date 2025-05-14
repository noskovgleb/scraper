# frozen_string_literal: true

require 'test_helper'

class ScraperServiceTest < ActiveSupport::TestCase
  setup do
    @valid_url = "https://example.com"
    @fields = { "title" => "h1", "paragraphs" => "p" }
  end

  test "raises error for invalid URL" do
    assert_raises(UrlValidatorService::InvalidUrlError) do
      ScraperService.scrape(url: "invalid-url", fields: @fields)
    end
  end

  test "calls ScraperLib::Client with correct parameters" do
    mock_client = Minitest::Mock.new
    mock_client.expect :scrape, { "title" => "Example Domain" }, [@fields]

    ScraperLib::Client.stub :new, mock_client do
      result = ScraperService.scrape(url: @valid_url, fields: @fields, use_browser: true)
      assert_equal({ "title" => "Example Domain" }, result)
    end

    mock_client.verify
  end

  test "passes use_browser parameter to client" do
    # Test with use_browser: true
    ScraperLib::Client.stub :new, ->(url, use_browser:) {
      assert_equal @valid_url, url
      assert_equal true, use_browser
      mock = Minitest::Mock.new
      mock.expect :scrape, {}, [@fields]
      mock
    } do
      ScraperService.scrape(url: @valid_url, fields: @fields, use_browser: true)
    end

    # Test with use_browser: false
    ScraperLib::Client.stub :new, ->(url, use_browser:) {
      assert_equal @valid_url, url
      assert_equal false, use_browser
      mock = Minitest::Mock.new
      mock.expect :scrape, {}, [@fields]
      mock
    } do
      ScraperService.scrape(url: @valid_url, fields: @fields, use_browser: false)
    end
  end
end