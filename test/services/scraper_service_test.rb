# frozen_string_literal: true

require "test_helper"

class ScraperServiceTest < ActiveSupport::TestCase
  setup do
    @valid_url = "https://example.com"
    @fields = { "title" => "h1", "paragraphs" => "p" }
    # Clear the cache before each test
    Rails.cache.clear
  end

  test "raises error for invalid URL" do
    assert_raises(UrlValidatorService::InvalidUrlError) do
      ScraperService.scrape(url: "invalid-url", fields: @fields)
    end
  end

  test "calls ScraperLib::Client with correct parameters" do
    mock_client = Minitest::Mock.new
    mock_client.expect :scrape, { "title" => "Example Domain" }, [ @fields ]

    ScraperLib::Client.stub :new, mock_client do
      result = ScraperService.scrape(url: @valid_url, fields: @fields, use_browser: true)
      assert_equal({ "title" => "Example Domain" }, result)
    end

    mock_client.verify
  end

  test "passes use_browser parameter to client" do
    # Test with use_browser: true
    ScraperLib::Client.stub :new, ->(url, use_browser:, timeout:, headers:) {
      assert_equal @valid_url, url
      assert_equal true, use_browser
      mock = Minitest::Mock.new
      mock.expect :scrape, {}, [ @fields ]
      mock
    } do
      ScraperService.scrape(url: @valid_url, fields: @fields, use_browser: true)
    end

    # Test with use_browser: false
    ScraperLib::Client.stub :new, ->(url, use_browser:, timeout:, headers:) {
      assert_equal @valid_url, url
      assert_equal false, use_browser
      mock = Minitest::Mock.new
      mock.expect :scrape, {}, [ @fields ]
      mock
    } do
      ScraperService.scrape(url: @valid_url, fields: @fields, use_browser: false)
    end
  end

  test "uses cache for repeated requests" do
    # Mock the client to return a unique result we can identify
    mock_result = { "title" => "Cached Result #{SecureRandom.hex(8)}" }

    mock_client = Minitest::Mock.new
    # The client should only be called once
    mock_client.expect :scrape, mock_result, [ @fields ]

    ScraperLib::Client.stub :new, mock_client do
      # First call should use the client
      first_result = ScraperService.scrape(url: @valid_url, fields: @fields)
      assert_equal mock_result, first_result

      # Second call should use the cache
      second_result = ScraperService.scrape(url: @valid_url, fields: @fields)
      assert_equal mock_result, second_result
    end

    # Verify the client was only called once
    mock_client.verify
  end

  test "skips cache when skip_cache is true" do
    mock_client = Minitest::Mock.new
    # The client should be called twice
    mock_client.expect :scrape, { "title" => "First call" }, [ @fields ]
    mock_client.expect :scrape, { "title" => "Second call" }, [ @fields ]

    ScraperLib::Client.stub :new, mock_client do
      # First call
      first_result = ScraperService.scrape(url: @valid_url, fields: @fields, skip_cache: true)
      assert_equal({ "title" => "First call" }, first_result)

      # Second call should not use cache
      second_result = ScraperService.scrape(url: @valid_url, fields: @fields, skip_cache: true)
      assert_equal({ "title" => "Second call" }, second_result)
    end

    mock_client.verify
  end

  test "handles additional client parameters" do
    # Test that the service correctly passes headers and timeout to the client
    ScraperLib::Client.stub :new, ->(url, headers: {}, use_browser: false, timeout: ScraperLib::Client::DEFAULT_TIMEOUT) {
      assert_equal @valid_url, url
      assert_equal({ "User-Agent" => "Test Agent" }, headers)
      assert_equal 60, timeout

      mock = Minitest::Mock.new
      mock.expect :scrape, {}, [ @fields ]
      mock
    } do
      ScraperService.scrape(
        url: @valid_url,
        fields: @fields,
        use_browser: false,
        headers: { "User-Agent" => "Test Agent" },
        timeout: 60
      )
    end
  end
end
