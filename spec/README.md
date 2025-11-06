# Test Suite Documentation

## Overview
This test suite provides comprehensive coverage for the refactored products services and controller.

## Test Structure

### Service Specs

#### 1. GeminiService (`spec/services/gemini_service_spec.rb`)
Tests for AI API integration:
- Successful API calls and response parsing
- Empty response handling
- API failure scenarios with Bugsnag notifications
- Exception handling
- Product confirmation message generation

**Coverage**: 6 examples

#### 2. Products::ValidatorService (`spec/services/products/validator_service_spec.rb`)
Tests for product validation logic:
- Valid SKU validation
- Missing SKU detection
- Blank/whitespace SKU handling
- Error message formatting

**Coverage**: 9 examples

#### 3. Products::CheckService (`spec/services/products/check_service_spec.rb`)
Tests for product check workflow orchestration:
- Validation failure handling
- Existing product detection
- New product addition flow
- Gemini confirmation message generation
- Error handling and Bugsnag notifications
- Dependency injection

**Coverage**: 11 examples

### Controller Specs

#### Ai::ProductsController (`spec/requests/ai/products_controller_spec.rb`)
Tests for API endpoint behavior:
- Successful product checks
- Existing product responses
- Validation error responses
- Internal error handling
- Parameter validation
- Strong parameters filtering

**Coverage**: 7 examples

## Running Tests

### Run all specs:
```bash
bundle exec rspec
```

### Run with documentation format:
```bash
bundle exec rspec --format documentation
```

### Run specific spec file:
```bash
bundle exec rspec spec/services/gemini_service_spec.rb
bundle exec rspec spec/services/products/validator_service_spec.rb
bundle exec rspec spec/services/products/check_service_spec.rb
bundle exec rspec spec/requests/ai/products_controller_spec.rb
```

### Run specific test:
```bash
bundle exec rspec spec/services/gemini_service_spec.rb:10
```

## Testing Tools

- **RSpec**: Testing framework
- **WebMock**: HTTP request stubbing
- **VCR**: HTTP interaction recording (configured but not currently used)
- **Factory Bot**: Fixture replacement library (available)
- **Faker**: Fake data generation (available)

## Configuration

### WebMock
- Disabled net connections except localhost
- Used for stubbing external API calls (Gemini)

### VCR
- Configured to ignore Google API hosts
- Cassettes stored in `spec/fixtures/vcr_cassettes/`
- API keys filtered in recordings

## Test Coverage Summary

**Total**: 33 examples, 0 failures

All services and controllers have comprehensive test coverage including:
- Happy path scenarios
- Error handling
- Edge cases
- Dependency injection
- External API mocking
