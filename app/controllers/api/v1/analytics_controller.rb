# app/controllers/api/v1/analytics_controller.rb
module Api
  module V1
    class AnalyticsController < BaseController
      def dashboard
        client = AnalyticsServiceClient.new
        dashboard_data = client.get_dashboard_data
        render json: dashboard_data
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      def reports
        client = AnalyticsServiceClient.new
        reports = client.get_reports(report_params)
        render json: reports
      rescue ServiceClient::ServiceError => e
        render json: { error: e.message }, status: :internal_server_error
      end
      
      private
      
      def report_params
        params.permit(:report_type, :start_date, :end_date, :granularity)
      end
    end
  end
end
