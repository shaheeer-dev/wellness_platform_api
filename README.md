# Virtual Wellness Platform API

**Take-Home Assignment - Intermediate/Senior Developer**

A Rails 7.2 API-only application for managing wellness clinic clients and appointments with external API integration.

## Related Projects

- **Frontend**: React TypeScript application located at `../wellness_platform_frontend/`
- **Backend**: This Rails API application

## Features

- **Client Management**: CRUD operations for clinic clients
- **Appointment Scheduling**: Create, read, update, and cancel appointments
- **External API Integration**: Sync with mock Postman API
- **Background Jobs**: Periodic data synchronization
- **Search & Filtering**: Find clients and filter appointments
- **Comprehensive Error Handling**: Robust error responses
- **CORS Support**: Ready for frontend integration

## Tech Stack

- **Ruby**: 3.2+
- **Rails**: 7.2.2
- **Database**: PostgreSQL
- **Background Jobs**: Sidekiq
- **API Serialization**: JSONAPI::Serializer
- **HTTP Client**: HTTParty
- **Testing**: RSpec, FactoryBot, WebMock
- **Pagination**: Pagy

## Setup Instructions

### Prerequisites

- Ruby 3.2 or higher
- PostgreSQL
- Bundler

### Installation

1. **Clone the repository**
   ```bash
   git clone [repository-url]
   cd wellness_platform_api
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Database setup**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed  # Optional: seed with sample data
   ```

4. **Start the server**
   ```bash
   rails server
   ```

5. **Start background jobs**
   ```bash
   bundle exec sidekiq
   ```

### Full-Stack Setup

To run the complete wellness platform:

1. **Start the Rails API** (this project):
   ```bash
   rails server  # Runs on http://localhost:3000
   ```

2. **Start the React Frontend** (separate project):
   ```bash
   cd ../wellness_platform_frontend
   npm install
   npm start     # Runs on http://localhost:3001
   ```

## Background Jobs

The application includes automatic periodic synchronization with the external API:

- **Clients**: Sync every 15 minutes
- **Appointments**: Sync every 10 minutes

Background jobs run automatically and handle data synchronization transparently.

## Testing

Run the test suite:

```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/client_spec.rb

# Run with coverage
bundle exec rspec --format documentation
```

## Configuration

### External API Configuration

The external API URL is configured in `config/initializers/constants.rb`:

```ruby
EXTERNAL_API_BASE_URI = 'https://your-postman-mock-server.mock.pstmn.io'.freeze
```

### External API Setup

1. Import the Postman collection from the provided link
2. Set up a mock server in Postman  
3. Update the `EXTERNAL_API_BASE_URI` constant in `config/initializers/constants.rb` with your mock server URL
4. The API key is managed through Rails credentials (if needed)

## Architecture & Design Patterns

### Service Objects
- `ExternalApiService`: Handles all external API communication
- `DataSyncService`: Manages data synchronization logic

### Background Jobs
- `SyncClientsJob`: Periodic client data synchronization
- `SyncAppointmentsJob`: Periodic appointment data synchronization

### Error Handling
- Centralized error handling with `ErrorHandler` concern
- Structured JSON error responses
- Comprehensive logging

### Database Design
- Proper indexing for performance
- Foreign key constraints
- Unique constraints for data integrity

---

**Time Spent**: Approximately 8 hours

**Key Assumptions Made**:
- External API follows RESTful conventions
- Client external_id from API is unique and stable
- Appointment statuses are limited to: scheduled, completed, cancelled
- Phone number validation is flexible to accommodate various formats
- Background job failures should be logged but not block the application
