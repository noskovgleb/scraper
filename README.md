# Web Scraper API

A standalone Rails application that provides a simple interface for extracting data from webpages using CSS selectors.

## Overview

This API allows users to extract specific data from any webpage by providing a URL and CSS selectors for the desired elements. It supports both simple CSS selectors and meta tag extraction, with built-in caching to improve performance.

This project uses the [scraper_lib](https://github.com/noskovgleb/scraper_lib.git) library for the core scraping functionality.

## Quick Start

### Requirements

- Ruby 3.x
- Rails 8.x

### Installation

#### Using Docker

```bash
# Build the Docker image
docker-compose build

# Start the application
docker-compose up
```

The API will be available at `http://localhost:3000`.

### Example Usage

```
GET /data?url=https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm&fields[price]=.price-box__primary-price__value.js-price-box__primary-price__value&fields[rating_count]=.ratingCount&fields[rating_value]=.ratingValue&fields[meta][]=keywords&fields[meta][]=twitter:image&skip_cache=true
```

## Documentation

For detailed documentation on how to use the API, see [DOCUMENTATION.md](DOCUMENTATION.md).

## Testing

Run the test suite with:

```bash
rails test
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.
