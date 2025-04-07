module ServiceRegistry
  class << self
    def service_url(service_name)
      services[service_name.to_sym] || raise("Unknown service: #{service_name}")
    end

    private

    def services
      @services ||= begin
        config = Rails.application.credentials.dig(:service_registry) || {}
        {
          customer: config[:customer],
          order: config[:order],
          product: config[:product],
          analytics: config[:analytics]
        }.compact
      end
    end
  end
end