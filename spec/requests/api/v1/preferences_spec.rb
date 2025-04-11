# spec/requests/api/v1/preferences_spec.rb
require 'swagger_helper'

RSpec.describe 'Preferences API', type: :request do
  path '/api/v1/customers/{customer_id}/preferences' do
    parameter name: 'customer_id', in: :path, type: :string, description: 'Customer ID'
    
    get('list preferences') do
      tags 'Preferences'
      security [bearer_auth: []]
      produces 'application/json'
      
      response '200', 'preferences found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              customer_id: { type: :integer },
              key: { type: :string },
              value: { type: :string },
              created_at: { type: :string, format: 'date-time' },
              updated_at: { type: :string, format: 'date-time' }
            }
          }
          
        let(:Authorization) { "Bearer #{token}" }
        let(:customer_id) { '1' }
        let(:token) { 'valid_token' }
        
        before do
          # Mock the CustomerServiceClient
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:get_preferences).and_return([
            {
              id: 1,
              customer_id: 1,
              key: 'email_notifications',
              value: 'true',
              created_at: '2025-01-01T00:00:00Z',
              updated_at: '2025-01-01T00:00:00Z'
            },
            {
              id: 2,
              customer_id: 1,
              key: 'theme',
              value: 'dark',
              created_at: '2025-01-01T00:00:00Z',
              updated_at: '2025-01-01T00:00:00Z'
            }
          ])
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '401', 'unauthorized' do
        let(:customer_id) { '1' }
        let(:Authorization) { 'Bearer invalid_token' }
        
        before do
          # Mock authentication failure
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:get_preferences).and_raise(ServiceClient::UnauthorizedError.new('Unauthorized'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '404', 'customer not found' do
        let(:customer_id) { '999' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        
        before do
          # Mock customer not found
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:get_preferences).and_raise(ServiceClient::ResourceNotFoundError.new('Customer not found'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end
  end

  path '/api/v1/customers/{customer_id}/preferences/{id}' do
    parameter name: 'customer_id', in: :path, type: :string, description: 'Customer ID'
    parameter name: 'id', in: :path, type: :string, description: 'Preference key'
    
    get('show preference') do
      tags 'Preferences'
      security [bearer_auth: []]
      produces 'application/json'
      
      response '200', 'preference found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            key: { type: :string },
            value: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:Authorization) { "Bearer #{token}" }
        let(:customer_id) { '1' }
        let(:id) { 'email_notifications' }
        let(:token) { 'valid_token' }
        
        before do
          # Mock the CustomerServiceClient
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:get_preference).and_return(
            {
              id: 1,
              customer_id: 1,
              key: 'email_notifications',
              value: 'true',
              created_at: '2025-01-01T00:00:00Z',
              updated_at: '2025-01-01T00:00:00Z'
            }
          )
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '404', 'preference not found' do
        let(:customer_id) { '1' }
        let(:id) { 'nonexistent_preference' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        
        before do
          # Mock preference not found
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:get_preference).and_raise(ServiceClient::ResourceNotFoundError.new('Preference not found'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end

    put('update preference') do
      tags 'Preferences'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :preference, in: :body, schema: {
        type: :object,
        properties: {
          value: { type: :string }
        },
        required: ['value']
      }
      
      response '200', 'preference updated' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            key: { type: :string },
            value: { type: :string },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:Authorization) { "Bearer #{token}" }
        let(:customer_id) { '1' }
        let(:id) { 'email_notifications' }
        let(:token) { 'valid_token' }
        let(:preference) do
          {
            value: 'false'
          }
        end
        
        before do
          # Mock the CustomerServiceClient
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:update_preference).and_return(
            {
              id: 1,
              customer_id: 1,
              key: 'email_notifications',
              value: 'false',
              created_at: '2025-01-01T00:00:00Z',
              updated_at: '2025-01-02T00:00:00Z'
            }
          )
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '404', 'customer not found' do
        let(:customer_id) { '999' }
        let(:id) { 'email_notifications' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        let(:preference) do
          {
            value: 'false'
          }
        end
        
        before do
          # Mock customer not found
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:update_preference).and_raise(ServiceClient::ResourceNotFoundError.new('Customer not found'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '422', 'invalid request' do
        let(:customer_id) { '1' }
        let(:id) { 'email_notifications' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        let(:preference) do
          {
            # Missing required 'value' field
          }
        end
        
        before do
          # Mock validation error
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:update_preference).and_raise(ServiceClient::ServiceError.new('Invalid request'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end

    delete('delete preference') do
      tags 'Preferences'
      security [bearer_auth: []]
      
      response '204', 'preference deleted' do
        let(:Authorization) { "Bearer #{token}" }
        let(:customer_id) { '1' }
        let(:id) { 'email_notifications' }
        let(:token) { 'valid_token' }
        
        before do
          # Mock the CustomerServiceClient
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:delete_preference).and_return(nil)
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '404', 'preference not found' do
        let(:customer_id) { '1' }
        let(:id) { 'nonexistent_preference' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        
        before do
          # Mock preference not found
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:delete_preference).and_raise(ServiceClient::ResourceNotFoundError.new('Preference not found'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end
  end
end