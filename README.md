# DataBridge API Gateway

The DataBridge API Gateway serves as the centralized entry point for all client applications interacting with the DataBridge microservices ecosystem. It handles cross-cutting concerns like authentication, authorization, and request routing while providing a unified API experience.

## Overview

The API Gateway is built using Ruby on Rails in API-only mode, implementing an event-driven architecture to connect multiple backend services:

- **Customer Service**: Manages user accounts and profiles
- **Order Service**: Handles order processing and management
- **Product Service**: Maintains product catalog and inventory
- **Analytics Service**: Aggregates data for business intelligence

## Features

- **Authentication**: JWT-based authentication system
- **Authorization**: Role-based access control
- **Request Routing**: Directs traffic to appropriate microservices
- **Rate Limiting**: Prevents API abuse
- **Service Registry**: Manages service discovery
- **Swagger Documentation**: Self-documented API endpoints

## Getting Started

### Prerequisites

- Ruby 3.2.2
- Rails 7.1.5
- PostgreSQL
- Redis (for rate limiting)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/your-org/databridge-api-gateway.git
   cd databridge-api-gateway
   ```

2. Install dependencies:
   ```
   bundle install
   ```

3. Setup the database:
   ```
   rails db:create db:migrate
   ```

4. Start the server:
   ```
   rails s
   ```

### Configuration

- `jwt_secret_key`: Secret for JWT token generation/validation  
- `service_registry.customer`: URL for the Customer Service  
- `service_registry.order`: URL for the Order Service  
- `service_registry.product`: URL for the Product Service  
- `service_registry.analytics`: URL for the Analytics Service  

## API Documentation

API documentation is available through Swagger UI at `/api-docs` when the server is running.

### Key Endpoints

- **Authentication**
  - `POST /api/v1/auth/login`: Authenticate user
  - `POST /api/v1/auth/register`: Register new user
  - `POST /api/v1/auth/refresh`: Refresh authentication token

- **Customers**
  - `GET /api/v1/customers`: List customers
  - `GET /api/v1/customers/:id`: Get customer details
  - `POST /api/v1/customers`: Create customer
  - `PUT /api/v1/customers/:id`: Update customer
  - `DELETE /api/v1/customers/:id`: Delete customer

- **Orders**
  - `GET /api/v1/orders`: List orders
  - `GET /api/v1/orders/:id`: Get order details
  - `POST /api/v1/orders`: Create order
  - `PUT /api/v1/orders/:id`: Update order
  - `DELETE /api/v1/orders/:id`: Delete order

- **Products**
  - `GET /api/v1/products`: List products
  - `GET /api/v1/products/:id`: Get product details
  - `POST /api/v1/products`: Create product
  - `PUT /api/v1/products/:id`: Update product
  - `DELETE /api/v1/products/:id`: Delete product

- **Analytics**
  - `GET /api/v1/analytics/dashboard`: Get dashboard data
  - `GET /api/v1/analytics/reports`: Get analytics reports

## Architecture

The API Gateway implements a microservices architecture with the following components:

- **Middleware**: Authentication and rate limiting
- **Service Clients**: HTTP clients for communicating with microservices
- **Controllers**: Route handlers for client requests
- **Service Registry**: Configuration for service discovery


## Shared Libraries

The Gateway uses the `databridge_shared` gem for common functionality across services:

- JWT authentication utilities
- Event schemas
- Event publishing/subscribing clients

## Development

### Adding New Routes

To add new routes to backend services:

1. Add the route to `config/routes.rb`
2. Create a controller in `app/controllers/api/v1/`
3. Implement the service client in `app/services/`
4. Update Swagger documentation in `spec/requests/api/v1/`

### Testing

Run the test suite with:

```
rails spec
```

Generate updated Swagger documentation:

```
rails rswag:specs:swaggerize
```
