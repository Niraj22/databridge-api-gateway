# spec/requests/api/v1/inventories_spec.rb
require 'swagger_helper'

RSpec.describe 'Inventories API', type: :request do
  path '/api/v1/products/{product_id}/inventory' do
    parameter name: 'product_id', in: :path, type: :integer, description: 'Product ID'
    
    get 'Retrieves product inventory' do
      tags 'Inventories'
      security [bearer_auth: []]
      produces 'application/json'

      response '200', 'inventory found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            product_id: { type: :integer },
            quantity: { type: :integer },
            low_stock_threshold: { type: :integer },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:product_id) { '1' }
        run_test!
      end

      response '404', 'product not found' do
        let(:product_id) { '0' }
        run_test!
      end
    end

    put 'Updates product inventory' do
      tags 'Inventories'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :inventory, in: :body, schema: {
        type: :object,
        properties: {
          quantity: { type: :integer },
          low_stock_threshold: { type: :integer }
        },
        required: ['quantity']
      }

      response '200', 'inventory updated' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            product_id: { type: :integer },
            quantity: { type: :integer },
            low_stock_threshold: { type: :integer },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:product_id) { '1' }
        let(:inventory) { { quantity: 100, low_stock_threshold: 10 } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:product_id) { '1' }
        let(:inventory) { { quantity: -1 } } # Negative quantity should fail validation
        run_test!
      end
    end
  end

  path '/api/v1/inventories/batch' do
    post 'Batch updates multiple product inventories' do
      tags 'Inventories'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :batch_data, in: :body, schema: {
        type: :object,
        properties: {
          inventories: {
            type: :array,
            items: {
              type: :object,
              properties: {
                product_id: { type: :integer },
                quantity: { type: :integer }
              },
              required: ['product_id', 'quantity']
            }
          }
        },
        required: ['inventories']
      }

      response '200', 'batch update successful' do
        schema type: :object,
          properties: {
            updated: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  product_id: { type: :integer },
                  quantity: { type: :integer }
                }
              }
            }
          }
        
        let(:batch_data) { { inventories: [{ product_id: 1, quantity: 50 }, { product_id: 2, quantity: 75 }] } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:batch_data) { { inventories: [{ product_id: 1, quantity: -10 }] } }
        run_test!
      end
    end
  end
end