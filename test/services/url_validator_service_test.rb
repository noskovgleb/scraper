# frozen_string_literal: true

require "test_helper"

class UrlValidatorServiceTest < ActiveSupport::TestCase
  test "validates a valid HTTP URL" do
    assert_nothing_raised do
      UrlValidatorService.validate!("http://example.com")
    end
  end

  test "validates a valid HTTPS URL" do
    assert_nothing_raised do
      UrlValidatorService.validate!("https://example.com")
    end
  end

  test "raises error for blank URL" do
    assert_raises(UrlValidatorService::InvalidUrlError) do
      UrlValidatorService.validate!("")
    end
  end

  test "raises error for nil URL" do
    assert_raises(UrlValidatorService::InvalidUrlError) do
      UrlValidatorService.validate!(nil)
    end
  end

  test "raises error for invalid URL format" do
    assert_raises(UrlValidatorService::InvalidUrlError) do
      UrlValidatorService.validate!("not-a-url")
    end
  end

  test "raises error for non-HTTP/HTTPS URL" do
    assert_raises(UrlValidatorService::InvalidUrlError) do
      UrlValidatorService.validate!("ftp://example.com")
    end
  end
end
