require 'swagger_helper'

RSpec.describe 'Products API', type: :request do
  path '/api/v1/products' do
    get 'Lists products' do
      tags 'Products'
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false
      parameter name: :category, in: :query, type: :string, required: false
      parameter name: :sort_by, in: :query, type: :string, required: false
      parameter name: :sort_direction, in: :query, type: :string, required: false, enum: ['asc', 'desc']
      parameter name: :min_price, in: :query, type: :number, required: false
      parameter name: :max_price, in: :query, type: :number, required: false

      response '200', 'products found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :string },
                  name: { type: :string },
                  description: { type: :string },
                  price: { type: :number },
                  category_id: { type: :string },
                  inventory_count: { type: :integer },
                  active: { type: :boolean }
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
    end

    post 'Creates a product' do
      tags 'Products'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          price: { type: :number },
          category_id: { type: :string },
          inventory_count: { type: :integer },
          active: { type: :boolean }
        },
        required: ['name', 'price']
      }

      response '201', 'product created' do
        let(:product) { { name: 'New Product', price: 49.99 } }
        
        schema type: :object,
          properties: {
            id: { type: :string },
            name: { type: :string },
            description: { type: :string },
            price: { type: :number },
            category_id: { type: :string },
            inventory_count: { type: :integer },
            active: { type: :boolean }
          }
        
        run_test!
      end

      response '401', 'unauthorized' do
        let(:product) { { name: 'New Product', price: 49.99 } }
        
        schema '$ref' => '#/components/schemas/error'
        
        run_test!
      end

      response '422', 'invalid request' do
        let(:product) { { name: 'Invalid Product' } }
        
        schema '$ref' => '#/components/schemas/error'
        
        run_test!
      end
    end
  end

  # Other product paths would be similar to customers
end
