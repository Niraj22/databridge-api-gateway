# spec/requests/api/v1/categories_spec.rb
require 'swagger_helper'

RSpec.describe 'Categories API', type: :request do
  path '/api/v1/categories' do
    get 'Lists all categories' do
      tags 'Categories'
      produces 'application/json'
      
      parameter name: :include_inactive, in: :query, type: :boolean, required: false, description: 'Include inactive categories'
      parameter name: :parent_id, in: :query, type: :integer, required: false, description: 'Filter by parent category'
      parameter name: :root, in: :query, type: :boolean, required: false, description: 'Only return root categories'

      response '200', 'categories found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              description: { type: :string, nullable: true },
              parent_id: { type: :integer, nullable: true },
              active: { type: :boolean },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          }
        
        run_test!
      end
    end

    post 'Creates a category' do
      tags 'Categories'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          parent_id: { type: :integer, nullable: true },
          active: { type: :boolean }
        },
        required: ['name']
      }

      response '201', 'category created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            parent_id: { type: :integer, nullable: true },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:category) { { name: 'New Category', description: 'A test category' } }
        run_test!
      end

      response '422', 'invalid request' do
        let(:category) { { description: 'Missing name field' } }
        run_test!
      end
    end
  end

  path '/api/v1/categories/{id}' do
    parameter name: 'id', in: :path, type: :integer, description: 'Category ID'
    
    get 'Retrieves a category' do
      tags 'Categories'
      produces 'application/json'

      response '200', 'category found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            parent_id: { type: :integer, nullable: true },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' },
            subcategories: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :integer },
                  name: { type: :string },
                  description: { type: :string, nullable: true },
                  parent_id: { type: :integer },
                  active: { type: :boolean }
                }
              }
            }
          }
        
        let(:id) { '1' }
        run_test!
      end

      response '404', 'category not found' do
        let(:id) { '0' }
        run_test!
      end
    end

    put 'Updates a category' do
      tags 'Categories'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      
      parameter name: :category, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          description: { type: :string },
          parent_id: { type: :integer, nullable: true },
          active: { type: :boolean }
        }
      }

      response '200', 'category updated' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            name: { type: :string },
            description: { type: :string, nullable: true },
            parent_id: { type: :integer, nullable: true },
            active: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:id) { '1' }
        let(:category) { { name: 'Updated Category' } }
        run_test!
      end

      response '404', 'category not found' do
        let(:id) { '0' }
        let(:category) { { name: 'Updated Category' } }
        run_test!
      end
    end

    delete 'Deletes a category' do
      tags 'Categories'
      security [bearer_auth: []]
      
      response '204', 'category deleted' do
        let(:id) { '1' }
        run_test!
      end

      response '404', 'category not found' do
        let(:id) { '0' }
        run_test!
      end
    end
  end
end