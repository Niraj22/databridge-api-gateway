# spec/requests/api/v1/addresses_spec.rb
require 'swagger_helper'

RSpec.describe 'Addresses API', type: :request do
  path '/api/v1/customers/{customer_id}/addresses' do
    parameter name: 'customer_id', in: :path, type: :string, description: 'Customer ID'
    
    get('list addresses') do
      tags 'Addresses'
      security [bearer_auth: []]
      produces 'application/json'
      
      response '200', 'addresses found' do
        schema type: :array,
          items: {
            type: :object,
            properties: {
              id: { type: :integer },
              customer_id: { type: :integer },
              address_type: { type: :string },
              street: { type: :string },
              city: { type: :string },
              state: { type: :string, nullable: true },
              postal_code: { type: :string },
              country: { type: :string },
              is_default: { type: :boolean },
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
          allow(client).to receive(:get_addresses).and_return([
            {
              id: 1,
              customer_id: 1,
              address_type: 'shipping',
              street: '123 Main St',
              city: 'Boston',
              state: 'MA',
              postal_code: '02108',
              country: 'US',
              is_default: true,
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
          allow(client).to receive(:get_addresses).and_raise(ServiceClient::UnauthorizedError.new('Unauthorized'))
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
          allow(client).to receive(:get_addresses).and_raise(ServiceClient::ResourceNotFoundError.new('Customer not found'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end

    post('create address') do
      tags 'Addresses'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :address, in: :body, schema: {
        type: :object,
        properties: {
          address_type: { type: :string, enum: ['shipping', 'billing'] },
          street: { type: :string },
          city: { type: :string },
          state: { type: :string },
          postal_code: { type: :string },
          country: { type: :string },
          is_default: { type: :boolean }
        },
        required: ['address_type', 'street', 'city', 'postal_code', 'country']
      }
      
      response '201', 'address created' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            address_type: { type: :string },
            street: { type: :string },
            city: { type: :string },
            state: { type: :string, nullable: true },
            postal_code: { type: :string },
            country: { type: :string },
            is_default: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:Authorization) { "Bearer #{token}" }
        let(:customer_id) { '1' }
        let(:token) { 'valid_token' }
        let(:address) do
          {
            address_type: 'shipping',
            street: '123 Main St',
            city: 'Boston',
            state: 'MA',
            postal_code: '02108',
            country: 'US',
            is_default: true
          }
        end
        
        before do
          # Mock the CustomerServiceClient
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:create_address).and_return(
            {
              id: 1,
              customer_id: 1,
              address_type: 'shipping',
              street: '123 Main St',
              city: 'Boston',
              state: 'MA',
              postal_code: '02108',
              country: 'US',
              is_default: true,
              created_at: '2025-01-01T00:00:00Z',
              updated_at: '2025-01-01T00:00:00Z'
            }
          )
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '401', 'unauthorized' do
        let(:customer_id) { '1' }
        let(:Authorization) { 'Bearer invalid_token' }
        let(:address) do
          {
            address_type: 'shipping',
            street: '123 Main St',
            city: 'Boston',
            state: 'MA',
            postal_code: '02108',
            country: 'US',
            is_default: true
          }
        end
        
        before do
          # Mock authentication failure
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:create_address).and_raise(ServiceClient::UnauthorizedError.new('Unauthorized'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '422', 'invalid request' do
        let(:customer_id) { '1' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        let(:address) do
          {
            # Missing required fields
            street: '123 Main St'
          }
        end
        
        before do
          # Mock validation failure
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:create_address).and_raise(ServiceClient::ServiceError.new('Invalid request'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end
  end

  path '/api/v1/customers/{customer_id}/addresses/{id}' do
    parameter name: 'customer_id', in: :path, type: :string, description: 'Customer ID'
    parameter name: 'id', in: :path, type: :string, description: 'Address ID'
    
    get('show address') do
      tags 'Addresses'
      security [bearer_auth: []]
      produces 'application/json'
      
      response '200', 'address found' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            address_type: { type: :string },
            street: { type: :string },
            city: { type: :string },
            state: { type: :string, nullable: true },
            postal_code: { type: :string },
            country: { type: :string },
            is_default: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:Authorization) { "Bearer #{token}" }
        let(:customer_id) { '1' }
        let(:id) { '1' }
        let(:token) { 'valid_token' }
        
        before do
          # Mock the CustomerServiceClient
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:get_address).and_return(
            {
              id: 1,
              customer_id: 1,
              address_type: 'shipping',
              street: '123 Main St',
              city: 'Boston',
              state: 'MA',
              postal_code: '02108',
              country: 'US',
              is_default: true,
              created_at: '2025-01-01T00:00:00Z',
              updated_at: '2025-01-01T00:00:00Z'
            }
          )
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '404', 'address not found' do
        let(:customer_id) { '1' }
        let(:id) { '999' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        
        before do
          # Mock address not found
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:get_address).and_raise(ServiceClient::ResourceNotFoundError.new('Address not found'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end

    put('update address') do
      tags 'Addresses'
      security [bearer_auth: []]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :address, in: :body, schema: {
        type: :object,
        properties: {
          address_type: { type: :string, enum: ['shipping', 'billing'] },
          street: { type: :string },
          city: { type: :string },
          state: { type: :string },
          postal_code: { type: :string },
          country: { type: :string },
          is_default: { type: :boolean }
        }
      }
      
      response '200', 'address updated' do
        schema type: :object,
          properties: {
            id: { type: :integer },
            customer_id: { type: :integer },
            address_type: { type: :string },
            street: { type: :string },
            city: { type: :string },
            state: { type: :string, nullable: true },
            postal_code: { type: :string },
            country: { type: :string },
            is_default: { type: :boolean },
            created_at: { type: :string, format: 'date-time' },
            updated_at: { type: :string, format: 'date-time' }
          }
        
        let(:Authorization) { "Bearer #{token}" }
        let(:customer_id) { '1' }
        let(:id) { '1' }
        let(:token) { 'valid_token' }
        let(:address) do
          {
            street: '456 New St',
            city: 'New York',
            state: 'NY',
            postal_code: '10001',
            country: 'US'
          }
        end
        
        before do
          # Mock the CustomerServiceClient
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:update_address).and_return(
            {
              id: 1,
              customer_id: 1,
              address_type: 'shipping',
              street: '456 New St',
              city: 'New York',
              state: 'NY',
              postal_code: '10001',
              country: 'US',
              is_default: true,
              created_at: '2025-01-01T00:00:00Z',
              updated_at: '2025-01-02T00:00:00Z'
            }
          )
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '404', 'address not found' do
        let(:customer_id) { '1' }
        let(:id) { '999' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        let(:address) do
          {
            street: '456 New St',
            city: 'New York'
          }
        end
        
        before do
          # Mock address not found
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:update_address).and_raise(ServiceClient::ResourceNotFoundError.new('Address not found'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end

    delete('delete address') do
      tags 'Addresses'
      security [bearer_auth: []]
      
      response '204', 'address deleted' do
        let(:Authorization) { "Bearer #{token}" }
        let(:customer_id) { '1' }
        let(:id) { '1' }
        let(:token) { 'valid_token' }
        
        before do
          # Mock the CustomerServiceClient
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:delete_address).and_return(nil)
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end

      response '404', 'address not found' do
        let(:customer_id) { '1' }
        let(:id) { '999' }
        let(:Authorization) { "Bearer #{token}" }
        let(:token) { 'valid_token' }
        
        before do
          # Mock address not found
          client = instance_double(CustomerServiceClient)
          allow(client).to receive(:delete_address).and_raise(ServiceClient::ResourceNotFoundError.new('Address not found'))
          allow(CustomerServiceClient).to receive(:new).and_return(client)
        end
        
        run_test!
      end
    end
  end
end