# app/services/analytics_service_client.rb
class AnalyticsServiceClient < ServiceClient
  def initialize
    super(:analytics)
  end
  
  def get_dashboard_data
    get('/api/dashboard')
  end
  
  def get_reports(params = {})
    get('/api/reports', params)
  end
  
  def generate_report(report_params)
    post('/api/reports', report_params)
  end
end
