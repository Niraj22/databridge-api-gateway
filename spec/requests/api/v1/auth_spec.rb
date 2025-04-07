require 'swagger_helper'

RSpec.describe 'Authentication API', type: :request do
  path '/api/v1/auth/login' do
    post 'Authenticates user' do
      tags 'Authentication'
      consumes 'application/json'
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string }
        },
        required: ['email', 'password']
      }

      response '200', 'user authenticated' do
        let(:credentials) { { email: 'user@example.com', password: 'password123' } }
        
        schema type: :object,
          properties: {
            token: { type: :string },
            user: { 
              type: :object,
              properties: {
                id: { type: :string },
                email: { type: :string },
                name: { type: :string },
                roles: { 
                  type: :array,
                  items: { type: :string }
                }
              }
            }
          }
        
        run_test!
      end

      response '401', 'invalid credentials' do
        let(:credentials) { { email: 'user@example.com', password: 'wrong' } }
        
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        
        run_test!
      end
    end
  end

  path '/api/v1/auth/register' do
    post 'Registers a new user' do
      tags 'Authentication'
      consumes 'application/json'
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string },
          password: { type: :string },
          name: { type: :string },
          role: { type: :string, enum: ['customer', 'admin'] }
        },
        required: ['email', 'password', 'name']
      }

      response '201', 'user created' do
        let(:user) { { email: 'new@example.com', password: 'password123', name: 'New User' } }
        
        schema type: :object,
          properties: {
            token: { type: :string },
            user: { 
              type: :object,
              properties: {
                id: { type: :string },
                email: { type: :string },
                name: { type: :string }
              }
            }
          }
        
        run_test!
      end

      response '422', 'invalid request' do
        let(:user) { { email: 'invalid' } }
        
        schema type: :object,
          properties: {
            error: { type: :string }
          }
        
        run_test!
      end
    end
  end

  path '/api/v1/auth/refresh' do
    post 'Refreshes authentication token' do
      tags 'Authentication'
      security [bearer_auth: []]

      response '200', 'token refreshed' do
        schema type: :object,
          properties: {
            token: { type: :string }
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
  end
end
