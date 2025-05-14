# Web Scraper API Documentation

This document provides comprehensive documentation for the Web Scraper API, a standalone Rails application that allows users to extract data from webpages using CSS selectors.

## Overview

The Web Scraper API enables users to extract specific data from any webpage by providing a URL and CSS selectors for the desired elements. The API supports both simple CSS selectors and meta tag extraction, with built-in caching to improve performance.

This project uses the [scraper_lib](https://github.com/noskovgleb/scraper_lib.git) library for the core scraping functionality.

## API Endpoints

### GET /data

Extracts data from a webpage based on the provided URL and CSS selectors.

#### Request Parameters

| Parameter   | Type        | Required | Description                                                                |
| ----------- | ----------- | -------- | -------------------------------------------------------------------------- |
| url         | String      | Yes      | The URL of the webpage to scrape                                           |
| fields      | Object      | No       | A mapping of field names to CSS selectors                                  |
| use_browser | Boolean     | No       | Whether to use a headless browser for JavaScript rendering (default: true) |
| skip_cache  | Boolean     | No       | Whether to skip cache and force a fresh scrape (default: false)            |
| timeout     | Integer     | No       | Request timeout in seconds                                                 |
| headers     | JSON String | No       | Additional HTTP headers to send with the request                           |

#### Example Request

```
GET /data?url=https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm&fields[price]=.price-box__primary-price__value.js-price-box__primary-price__value&fields[rating_count]=.ratingCount&fields[rating_value]=.ratingValue&fields[meta][]=keywords&fields[meta][]=twitter:image&skip_cache=true
```

This request extracts:

- The price from elements with class `.price-box__primary-price__value.js-price-box__primary-price__value`
- The rating count from elements with class `.ratingCount`
- The rating value from elements with class `.ratingValue`
- The meta tags with names "keywords" and "twitter:image"

The `skip_cache=true` parameter forces a fresh scrape, bypassing any cached results.

#### Response Format

The API returns a JSON object with the extracted data. Each key in the response corresponds to a field name from the request, and its value is the extracted content.

```json
{
  "price": "18290,-",
  "rating_value": "4,9",
  "rating_count": "7 hodnocení",
  "meta": {
    "keywords": "Parní pračka AEG 7000 ProSteam® LFR73964CC na www.alza.cz. ✅ Bezpečný nákup. ✅ Veškeré informace o produktu. ✅ Vhodné příslušenství. ✅ Hodnocení a recenze AEG...",
    "twitter:image": "https://image.alza.cz/products/AEGPR065/AEGPR065.jpg?width=360&height=360"
  }
}
```

## Features

### Basic Scraping

Extract data using CSS selectors:

```
GET /data?url=https://example.com&fields[title]=h1&fields[description]=.description
```

### Meta Tag Extraction

Extract meta tag content by specifying the name attribute:

```
GET /data?url=https://example.com&fields[meta][]=description&fields[meta][]=keywords
```

### Caching

By default, scraping results are cached for 1 hour to improve performance. To force a fresh scrape, use the `skip_cache=true` parameter:

```
GET /data?url=https://example.com&fields[title]=h1&skip_cache=true
```

### JavaScript Rendering

By default, the API uses a headless browser to render JavaScript before scraping. To disable this and use a simpler HTTP request:

```
GET /data?url=https://example.com&fields[title]=h1&use_browser=false
```

### Custom Timeout

Set a custom timeout for the scraping request:

```
GET /data?url=https://example.com&fields[title]=h1&timeout=60
```

### Custom Headers

Send custom HTTP headers with the scraping request:

```
GET /data?url=https://example.com&fields[title]=h1&headers={"User-Agent":"Custom Agent"}
```

## Error Handling

The API returns appropriate HTTP status codes and error messages:

- `400 Bad Request`: Invalid URL or missing required parameters
- `422 Unprocessable Entity`: Failed to parse the HTML content
- `503 Service Unavailable`: Failed to fetch the webpage
- `500 Internal Server Error`: Unexpected errors

Error responses include a JSON object with an error message:

```json
{
  "error": {
    "message": "Invalid URL format"
  }
}
```

## Implementation Details

This API is built with Ruby on Rails and uses the [scraper_lib](https://github.com/noskovgleb/scraper_lib.git) library for web scraping. The library supports both simple HTTP requests and headless browser rendering for JavaScript-heavy websites.

### Caching

The API uses Rails' caching mechanism to store scraping results for 1 hour. This reduces load times and minimizes the number of requests to target websites.

### Security

The API validates all URLs before scraping to ensure they use the HTTP or HTTPS protocol.

## Development

### Requirements

- Ruby 3.x
- Rails 8.x
- [scraper_lib](https://github.com/noskovgleb/scraper_lib.git)

### Running the Application using Docker

```bash
# Clone the repository
git clone <repository-url>

# Build the Docker image
docker-compose build

# Start the application
docker-compose up
```

The API will be available at `http://localhost:3000`.

## Testing

Run the test suite with:

```bash
rails test
```
