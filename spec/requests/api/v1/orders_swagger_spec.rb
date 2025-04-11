# spec/requests/api/v1/orders_swagger_spec.rb
require 'swagger_helper'

RSpec.describe 'Orders API', type: :request do
  path '/api/v1/orders' do
    get 'Lists all orders' do
      tags 'Orders'
      produces 'application/json'
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :status, in: :query, type: :string, required: false, description: 'Filter by status (created, processing, fulfilled, canceled)'
      parameter name: :customer_id, in: :query, type: :integer, required: false, description: 'Filter by customer ID'
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false, description: 'Filter by start date (YYYY-MM-DD)'
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false, description: 'Filter by end date (YYYY-MM-DD)'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Field to sort by (created_at, total_amount, status)'
      parameter name: :sort_direction, in: :query, type: :string, required: false, enum: ['asc', 'desc'], description: 'Sort direction'
      security [bearer_auth: []]

      response '200', 'orders found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              customer_id: { type: :integer },
              status: { type: :string, enum: ['created', 'processing', 'fulfilled', 'canceled'] },
              total_amount: { type: :number, format: :float },
              notes: { type: :string, nullable: true },
              created_at: { type: :string, format: :'date-time' },
              updated_at: { type: :string, format: :'date-time' }
            }
          }
        run_test!
      end
      
      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
    end

    post 'Creates an order' do
      tags 'Orders'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          line_items: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :integer },
                quantity: { type: :integer },
                unit_price: { type: :number, format: :float }
              },
              required: ['product_id', 'quantity', 'unit_price']
            }
          }
        },
        required: ['line_items']
      }

      response '201', 'order created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            status: { type: :string },
            total_amount: { type: :number, format: :float },
            notes: { type: :string, nullable: true },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' }
          }
        run_test!
      end

      response '422', 'invalid request' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        run_test!
      end
      
      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
    end
  end

  path '/api/v1/orders/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'Order ID'

    get 'Retrieves an order' do
      tags 'Orders'
      produces 'application/json'
      security [bearer_auth: []]

      response '200', 'order found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            status: { type: :string },
            total_amount: { type: :number, format: :float },
            notes: { type: :string, nullable: true },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' },
            line_items: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_id: { type: :integer },
                  product_id: { type: :integer },
                  quantity: { type: :integer },
                  unit_price: { type: :number, format: :float },
                  total_price: { type: :number, format: :float },
                  created_at: { type: :string, format: :'date-time' },
                  updated_at: { type: :string, format: :'date-time' }
                }
              }
            },
            payments: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_id: { type: :integer },
                  amount: { type: :number, format: :float },
                  payment_method: { type: :string },
                  status: { type: :string },
                  transaction_id: { type: :string, nullable: true },
                  created_at: { type: :string, format: :'date-time' },
                  updated_at: { type: :string, format: :'date-time' }
                }
              }
            },
            shipments: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  order_id: { type: :integer },
                  tracking_number: { type: :string, nullable: true },
                  carrier: { type: :string, nullable: true },
                  status: { type: :string },
                  created_at: { type: :string, format: :'date-time' },
                  updated_at: { type: :string, format: :'date-time' }
                }
              }
            }
          }
        run_test!
      end

      response '404', 'order not found' do
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
      
      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
    end

    put 'Updates an order' do
      tags 'Orders'
      consumes 'application/json'
      produces 'application/json'
      security [bearer_auth: []]
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          status: { type: :string, enum: ['created', 'processing', 'fulfilled', 'canceled'] }
        }
      }

      response '200', 'order updated' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            status: { type: :string },
            total_amount: { type: :number, format: :float },
            notes: { type: :string, nullable: true },
            created_at: { type: :string, format: :'date-time' },
            updated_at: { type: :string, format: :'date-time' }
          }
        run_test!
      end

      response '404', 'order not found' do
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
      
      response '422', 'invalid request' do
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        run_test!
      end
      
      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
    end

    delete 'Cancels an order' do
      tags 'Orders'
      security [bearer_auth: []]

      response '204', 'order canceled' do
        run_test!
      end

      response '404', 'order not found' do
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
      
      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'
        run_test!
      end
    end
  end
end