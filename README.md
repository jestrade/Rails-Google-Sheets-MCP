# Rails Google Sheets MCP

This is a minimal Rails API (microservice) that receives a product and checks if it exists in a Google Sheets spreadsheet. If the product exists it returns the product data; if it doesn't exist it adds the product to the sheet and returns the created row.

## Overview

- Rails API-only app (no DB required)
- Uses `google_drive` gem to interact with Google Sheets using a Service Account
- Exposes a single endpoint: POST /api/v1/products

## Ruby version
`ruby 3.4.7`

## System dependencies
- gem 'google_drive', '~> 3.3'
- gem 'dotenv-rails', groups: [:development, :test]

Run `bundle install` after adding.

## Configuration

Create a `.env` file with the following variables:
```
GOOGLE_SERVICE_ACCOUNT_JSON=google_service_account_key.json
GOOGLE_SHEET_KEY=<gsheet_key>
BUGSNAG_API_KEY=<bugsnag_api_key>
```

Tip: share the spreadsheet with the service account email (found in the JSON) with Editor permissions.

## How to run the test suite

## Services (job queues, cache servers, search engines, etc.)

## Execute server
```
rails s
```


## Behavior
- Search the sheet for a row where the SKU column matches `sku`.
- If found: return 200 + the row as JSON.
- If not found: append a new row, return 201 + the new row as JSON.

# Example usage (curl)
```bash
curl -X POST http://localhost:3000/api/v1/products \
-H "Content-Type: application/json" \
-d '{"product":{"sku":"ABC-123","name":"My product","price":"12.50","metadata":"from api"}}'
```


Responses:
- If exists (200):


```json
{ "exists": true, "product": { "sku":"ABC-123", "name":"My product", "price":"12.50", "metadata":"..." } }
```


- If created (201):


```json
{ "exists": false, "created": { "sku":"ABC-123", "name":"My product", "price":"12.50", "metadata":"from api" } }
```


# Deployment / notes

- For local dev put `GOOGLE_SERVICE_ACCOUNT_JSON` into `.env`, set `GOOGLE_SERVICE_ACCOUNT_JSON=/path/to/key.json` and ensure the file is present in the container.
- Make sure the service account email (from the key JSON) is added as an editor to the spreadsheet.
- For production use, enforce rate limiting and authentication. Google Sheets is not a true database — consider using a DB for heavy load.


# Testing suggestions
- Create a test spreadsheet with headers: `sku, name, price, metadata`
- Test with duplicate SKUs and verify matching behavior
