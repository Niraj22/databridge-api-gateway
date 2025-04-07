require 'swagger_helper'

RSpec.describe 'Customers API', type: :request do
  path '/api/v1/customers' do
    get 'Lists customers' do
      tags 'Customers'
      security [bearer_auth: []]
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :per_page, in: :query, type: :integer, required: false
      parameter name: :sort_by, in: :query, type: :string, required: false
      parameter name: :sort_direction, in: :query, type: :string, required: false, enum: ['asc', 'desc']

      response '200', 'customers found' do
        schema type: :object,
          properties: {
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  id: { type: :string },
                  name: { type: :string },
                  email: { type: :string }
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
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        
        run_test!
      end
    end

    post 'Creates a customer' do
      tags 'Customers'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string },
          password: { type: :string },
          role: { type: :string }
        },
        required: ['name', 'email', 'password']
      }

      response '201', 'customer created' do
        let(:customer) { { name: 'New Customer', email: 'customer@example.com', password: 'password123' } }
        
        schema type: :object,
          properties: {
            id: { type: :string },
            name: { type: :string },
            email: { type: :string }
          }
        
        run_test!
      end

      response '422', 'invalid request' do
        let(:customer) { { name: 'Invalid Customer' } }
        
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        
        run_test!
      end
    end
  end

  path '/api/v1/customers/{id}' do
    parameter name: :id, in: :path, type: :string

    get 'Retrieves a customer' do
      tags 'Customers'
      security [bearer_auth: []]

      response '200', 'customer found' do
        let(:id) { '123' }
        
        schema type: :object,
          properties: {
            id: { type: :string },
            name: { type: :string },
            email: { type: :string }
          }
        
        run_test!
      end

      response '404', 'customer not found' do
        let(:id) { 'invalid' }
        
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        
        run_test!
      end
    end

    put 'Updates a customer' do
      tags 'Customers'
      security [bearer_auth: []]
      consumes 'application/json'
      parameter name: :customer, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          email: { type: :string }
        }
      }

      response '200', 'customer updated' do
        let(:id) { '123' }
        let(:customer) { { name: 'Updated Customer' } }
        
        schema type: :object,
          properties: {
            id: { type: :string },
            name: { type: :string },
            email: { type: :string }
          }
        
        run_test!
      end

      response '404', 'customer not found' do
        let(:id) { 'invalid' }
        let(:customer) { { name: 'Updated Customer' } }
        
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        
        run_test!
      end
    end

    delete 'Deletes a customer' do
      tags 'Customers'
      security [bearer_auth: []]

      response '204', 'customer deleted' do
        let(:id) { '123' }
        
        run_test!
      end

      response '404', 'customer not found' do
        let(:id) { 'invalid' }
        
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        
        run_test!
      end
    end
  end
end
