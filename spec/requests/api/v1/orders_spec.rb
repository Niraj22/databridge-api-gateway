require 'swagger_helper'

RSpec.describe 'Orders API', type: :request do
  path '/api/v1/orders' do
    get 'Lists orders' do
      tags 'Orders'
      security [bearer_auth: []]
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false
      parameter name: :status, in: :query, type: :string, required: false
      parameter name: :sort_by, in: :query, type: :string, required: false
      parameter name: :sort_direction, in: :query, type: :string, required: false, enum: ['asc', 'desc']
      parameter name: :start_date, in: :query, type: :string, format: :date, required: false
      parameter name: :end_date, in: :query, type: :string, format: :date, required: false

      response '200', 'orders found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :string },
                  user_id: { type: :string },
                  status: { type: :string },
                  total: { type: :number },
                  created_at: { type: :string, format: :date_time },
                  updated_at: { type: :string, format: :date_time }
                }
              }
            },
            meta: {
              type: :object,
              properties: {
                total: { type: :integer },
                page: { type: :integer },
                per_page: { type: :integer }
              }
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
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :order, in: :body, schema: {
        type: :object,
        properties: {
          products: { 
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :string },
                quantity: { type: :integer }
              }
            }
          },
          shipping_address: {
            type: :object,
            properties: {
              street: { type: :string },
              city: { type: :string },
              state: { type: :string },
              zip: { type: :string },
              country: { type: :string }
            }
          },
          payment_method: { type: :string },
          notes: { type: :string }
        },
        required: ['products', 'shipping_address', 'payment_method']
      }

      response '201', 'order created' do
        let(:order) do
          { 
            products: [{ product_id: '123', quantity: 2 }],
            shipping_address: { street: '123 Main St', city: 'Anytown', state: 'CA', zip: '12345', country: 'USA' },
            payment_method: 'credit_card'
          }
        end
        
        schema type: :object,
          properties: {
            id: { type: :string },
            user_id: { type: :string },
            status: { type: :string },
            total: { type: :number },
            created_at: { type: :string, format: :date_time },
            updated_at: { type: :string, format: :date_time }
          }
        
        run_test!
      end

      response '401', 'unauthorized' do
        let(:order) { {} }
        
        schema '$ref' => '#/components/schemas/error'
        
        run_test!
      end

      response '422', 'invalid request' do
        let(:order) { { products: [] } }
        
        schema '$ref' => '#/components/schemas/error'
        
        run_test!
      end
    end
  end

  # Other order paths would be similar to customers
end
