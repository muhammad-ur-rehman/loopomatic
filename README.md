# Loopomatic - Return Request Processing System

A Rails API application that processes return requests through an automated pipeline: AI classification, rule evaluation, and external API enrichment.

## Overview

This application implements a small slice of an automation platform for handling return requests. It demonstrates:

- **AI/ML Integration**: Keyword-based classification (easily swappable for real AI APIs)
- **Rule Engine**: Flexible rule evaluation system with condition matching and action application
- **External API Integration**: Data enrichment via REST APIs (REST Countries, NHTSA Vehicle API)
- **Simple UI**: Basic web interface for creating and viewing return requests
- **Discontinued Models Module**: Business logic for identifying discontinued vehicle models

## Tech Stack

- **Rails 8.1.1** with API-friendly controllers plus HTML views
- **PostgreSQL** for persistence
- **Sidekiq + Redis** for background processing
- **Faraday** for outbound HTTP requests
- **RSpec + FactoryBot** for application specs

## Setup Instructions

### Prerequisites

- Ruby 3.0+ (check `.ruby-version`)
- PostgreSQL
- Bundler

### Installation

1. **Clone the repository** (or extract the zip file)

2. **Install dependencies**:
   ```bash
   bundle install
   ```

   Sidekiq requires Redis. To run background jobs locally:
   ```bash
   brew install redis
   brew services start redis
   bundle exec sidekiq -C config/sidekiq.yml
   ```

   To run Rails + Sidekiq together using `Procfile.dev`, install Foreman:
   ```bash
   gem install foreman
   foreman start -f Procfile.dev
   ```

3. **Set up the database**:
   ```bash
   bin/rails db:create
   bin/rails db:migrate
   bin/rails db:seed
   ```

4. **Start the server**:
   ```bash
   bin/rails server
   ```

The application will be available at `http://localhost:3000`

## API Endpoints

### Return Requests

#### POST /return_requests
Create a new return request. The controller responds immediately (HTTP 202) while the job runs in the background.

**Request Body:**
```json
{
  "return_request": {
    "order_id": "ORD-1001",
    "customer_id": "CUST-42",
    "order_value_cents": 12999,
    "currency": "EUR",
    "reason": "damaged",
    "description": "The cover is broken and the machine is not turning on.",
    "metadata": {
      "country": "DE",
      "channel": "online_store"
    }
  }
}
```

**Response (HTTP 202):**
```json
{
  "return_request": {
    "id": 42,
    "order_id": "ORD-1001",
    "customer_id": "CUST-42",
    "order_value_cents": 12999,
    "currency": "EUR",
    "reason": "damaged",
    "description": "The cover is broken and the machine is not turning on.",
    "decision": null,
    "resolution": null,
    "ai_classification": null,
    "metadata": {
      "country": "DE",
      "channel": "online_store"
    },
    "created_at": "2025-11-29T12:00:00Z",
    "updated_at": "2025-11-29T12:00:00Z"
  },
  "message": "Return request processing has been queued. Check back shortly for AI decision."
}
```

#### GET /return_requests
List all return requests.

#### GET /return_requests/:id
Get details of a specific return request.

### Rules

#### GET /rules
List all rules (ordered by priority).

### Sidekiq Dashboard

`GET /sidekiq` (development only) shows live queues, processed jobs, and retries.

### Vehicle Models Integration

#### GET /integrations/vehicle_models
Fetch vehicle models for a specific make and year from NHTSA API.

**Parameters:**
- `make` (required): Vehicle make (e.g., "honda")
- `year` (required): Model year (e.g., 2016)

#### GET /integrations/discontinued_models
Calculate which vehicle models are discontinued based on time-window logic.

**Parameters:**
- `make` (required)
- `from_year` (required)
- `to_year` (required)
- `gap_years` (optional, default 2)

**Logic:**
- Appears in any year `[from_year, to_year - gap_years]`
- Absent in the last `gap_years` (`[to_year - gap_years + 1, to_year]`)

## Background Jobs & Async Flow

- **Trigger point:** `ReturnRequestsController#create` saves the record and enqueues `ReturnRequestProcessorJob`.
- **Job location:** `app/jobs/return_request_processor_job.rb`. The job loads the record and calls `Services::ReturnRequestProcessor.process` to run AI, rules, and enrichment.
- **Benefits:** the controller responds immediately with HTTP 202 while the heavy lifting runs in Sidekiq, so slow external APIs or AI steps don’t block the request/response cycle.
- **Monitoring:** start Sidekiq (`bundle exec sidekiq -C config/sidekiq.yml`) and open `/sidekiq` to inspect job status, queues, and retries.

## Architecture

### Service Objects

All business logic is encapsulated in service objects under `app/services/`:

- **`Services::AiClient`**: AI classification service (currently mock/keyword-based)
- **`Services::RuleEvaluator`**: Evaluates rule conditions and applies actions
- **`Services::ExternalApiClient`**: Enriches data via external REST APIs
- **`Services::ReturnRequestProcessor`**: Orchestrates the full processing pipeline
- **`Services::VehicleModelsClient`**: Integrates with NHTSA Vehicle API
- **`Services::DiscontinuedModelsCalculator`**: Implements discontinued models business logic

### Processing Pipeline

When a return request is created:

1. **AI Classification**: `Services::AiClient` classifies the description/reason
2. **Rule Evaluation**: Active rules are evaluated in priority order (lower number = earlier)
3. **External Enrichment**: Additional data is fetched and stored in metadata

### Rule Format

Rules are stored in the database with JSON conditions and actions:

**Conditions:**
```json
{
  "all": [
    { "field": "order_value_cents", "operator": ">", "value": 10000 },
    { "field": "ai_classification.category", "operator": "=", "value": "defect_item" }
  ]
}
```

Supported operators: `=`, `>`, `<`, `>=`, `<=`, `!=`, `includes`, `contains`

**Actions:**
```json
{
  "set_decision": "approved",
  "set_resolution": "refund"
}
```

### AI Integration

The `Services::AiClient` currently uses keyword-based classification. To swap for a real AI API (e.g., OpenAI):

1. Replace the `classify` method in `app/services/ai_client.rb`
2. Add API key to credentials: `bin/rails credentials:edit`
3. Make HTTP call to your AI provider

Example structure:
```ruby
def classify
  response = Faraday.post("https://api.openai.com/v1/chat/completions") do |req|
    req.headers['Authorization'] = "Bearer #{Rails.application.credentials.openai_api_key}"
    req.body = { ... }.to_json
  end
  # Parse and return structured response
end
```

## UI

Return request views share partials so the markup stays DRY and easy to tweak:

- `_form.html.erb` drives both the new page and any future edit form.
- `_index_table.html.erb` renders the table + empty state for the index page.
- `_detail_table.html.erb` holds the basic info rows on the show page.

Screens:

- `GET /return_requests` — list view with quick stats/link to details
- `GET /return_requests/new` — create form (posts to `/return_requests`)
- `GET /return_requests/:id` — detail view with AI output, metadata, and decision

## Testing

- Preferred command: `bundle exec rspec`
- Key specs:
  - `spec/models/return_request_spec.rb`
  - `spec/models/rule_spec.rb`
  - `spec/services/ai_client_spec.rb`
  - `spec/services/rule_evaluator_spec.rb`
  - `spec/services/discontinued_models_calculator_spec.rb`
  - `spec/jobs/return_request_processor_job_spec.rb`
- Legacy `test/` files remain from the Rails scaffold but RSpec is the active suite.

## Controller Helpers

Two concerns keep controllers lean:

- `Respondable` (JSON helpers + shared error handling)
- `ErrorHandling` (validation errors mapped to consistent responses)

Both are included in `ApplicationController`, so every controller gets the same behavior without repeating render logic.

## Sample Data



Load seed data: `bin/rails db:seed`

## What Would Be Improved With More Time

1. **Error Handling**: More robust error handling and retry logic for external APIs
2. **Caching**: Cache vehicle model data to reduce API calls
3. **Background Jobs**: Move external API calls to background jobs for better performance
4. **API Versioning**: Add API versioning (`/api/v1/...`)
5. **Authentication**: Add API authentication/authorization
6. **Pagination**: Add pagination to list endpoints
7. **Filtering/Search**: Add filtering and search capabilities
8. **Real AI Integration**: Replace mock AI with actual OpenAI/Anthropic integration
9. **More Tests**: Expand test coverage, especially integration tests
10. **API Documentation**: Add Swagger/OpenAPI documentation
11. **Logging**: Enhanced logging and monitoring
12. **Rate Limiting**: Add rate limiting for external API calls

## Known Limitations

- AI classification is keyword-based (mock implementation)
- No authentication/authorization
- No pagination on list endpoints
- External API calls are synchronous (could block requests)
- Limited error recovery for external API failures
- No caching of vehicle model data

## Environment Variables

No environment variables are currently required. For production, you may want to add:
- Database credentials
- AI API keys (if using real AI service)
- External API rate limiting configuration

## Postman Collection

Import `postman_collection.json` into Postman to hit every available endpoint (create/list/show return requests, list rules, vehicle/discontinued models) with sample payloads.


