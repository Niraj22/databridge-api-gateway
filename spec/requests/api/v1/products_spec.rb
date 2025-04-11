# spec/requests/api/v1/products_spec.rb
require 'swagger_helper'

RSpec.describe 'Products API', type: :request do
  path '/api/v1/products' do
    get 'Lists all products' do
      tags 'Products'
      produces 'application/json'
      
      parameter name: :page, in: :query, type: :integer, required: false, description: 'Page number'
      parameter name: :per_page, in: :query, type: :integer, required: false, description: 'Items per page'
      parameter name: :category_id, in: :query, type: :integer, required: false, description: 'Filter by category'
      parameter name: :price_min, in: :query, type: :number, required: false, description: 'Minimum price'
      parameter name: :price_max, in: :query, type: :number, required: false, description: 'Maximum price'
      parameter name: :sort_by, in: :query, type: :string, required: false, description: 'Field to sort by'
      parameter name: :sort_direction, in: :query, type: :string, required: false, description: 'Sort direction (asc or desc)'
      parameter name: :include_inactive, in: :query, type: :boolean, required: false, description: 'Include inactive products'

      response '200', 'products found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              description: { type: :string, nullable: true },
              sku: { type: :string },
              price: { type: :number, format: :float },
              active: { type: :boolean },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          }
        
        run_test!
      end
    end

    post 'Creates a product' do
      tags 'Products'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          sku: { type: :string },
          price: { type: :number, format: :float },
          active: { type: :boolean }
        },
        required: ['name', 'price']
      }

      response '201', 'product created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            sku: { type: :string },
            price: { type: :number, format: :float },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:product) { { name: 'New Product', price: 29.99, description: 'A new test product' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:product) { { description: 'Missing required fields' } }
        run_test!
      end
    end
  end

  path '/api/v1/products/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Product ID'
    
    get 'Retrieves a product' do
      tags 'Products'
      produces 'application/json'

      response '200', 'product found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            sku: { type: :string },
            price: { type: :number, format: :float },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' },
            categories: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string }
                }
              }
            },
            inventory: {
              type: :object,
              properties: {
                id: { type: :integer },
                quantity: { type: :integer },
                low_stock_threshold: { type: :integer }
              }
            }
          }
        
        let(:id) { '1' }
        run_test!
      end

      response '404', 'product not found' do
        let(:id) { '0' }
        run_test!
      end
    end

    put 'Updates a product' do
      tags 'Products'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          price: { type: :number, format: :float },
          active: { type: :boolean }
        }
      }

      response '200', 'product updated' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            sku: { type: :string },
            price: { type: :number, format: :float },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:id) { '1' }
        let(:product) { { name: 'Updated Product', price: 39.99 } }
        run_test!
      end

      response '404', 'product not found' do
        let(:id) { '0' }
        let(:product) { { name: 'Updated Product' } }
        run_test!
      end
    end

    delete 'Deletes a product' do
      tags 'Products'
      security [bearer_auth: []]
      
      response '204', 'product deleted' do
        let(:id) { '1' }
        run_test!
      end

      response '404', 'product not found' do
        let(:id) { '0' }
        run_test!
      end
    end
  end
end