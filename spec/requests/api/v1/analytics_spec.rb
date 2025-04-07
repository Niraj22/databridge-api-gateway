require 'swagger_helper'

RSpec.describe 'Analytics API', type: :request do
  path '/api/v1/analytics/dashboard' do
    get 'Gets dashboard data' do
      tags 'Analytics'
      security [bearer_auth: []]

      response '200', 'dashboard data found' do
        schema type: :object,
          properties: {
            sales: {
              type: :object,
              properties: {
                total: { type: :number },
                today: { type: :number },
                this_week: { type: :number },
                this_month: { type: :number }
              }
            },
            orders: {
              type: :object,
              properties: {
                total: { type: :integer },
                pending: { type: :integer },
                completed: { type: :integer },
                cancelled: { type: :integer }
              }
            },
            customers: {
              type: :object,
              properties: {
                total: { type: :integer },
                new_today: { type: :integer },
                active: { type: :integer }
              }
            },
            products: {
              type: :object,
              properties: {
                total: { type: :integer },
                out_of_stock: { type: :integer },
                top_selling: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      name: { type: :string },
                      sales: { type: :integer }
                    }
                  }
                }
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
  end

  path '/api/v1/analytics/reports' do
    get 'Gets analytics reports' do
      tags 'Analytics'
      security [bearer_auth: []]
      parameter name: :report_type, in: :query, type: :string, required: true, 
                enum: ['sales', 'orders', 'products', 'customers']
      parameter name: :start_date, in: :query, type: :string, format: :date, required: true
      parameter name: :end_date, in: :query, type: :string, format: :date, required: true
      parameter name: :granularity, in: :query, type: :string, required: false, 
                enum: ['day', 'week', 'month']

      response '200', 'report data found' do
        schema type: :object,
          properties: {
            report_type: { type: :string },
            start_date: { type: :string, format: :date },
            end_date: { type: :string, format: :date },
            granularity: { type: :string },
            data: {
              type: :array,
              items: {
                type: :object,
                properties: {
                  date: { type: :string },
                  value: { type: :number }
                }
              }
            }
          }
        
        run_test!
      end

      response '401', 'unauthorized' do
        schema '$ref' => '#/components/schemas/error'
        
        run_test!
      end

      response '422', 'invalid request' do
        schema '$ref' => '#/components/schemas/error'
        
        run_test!
      end
    end
  end
end
