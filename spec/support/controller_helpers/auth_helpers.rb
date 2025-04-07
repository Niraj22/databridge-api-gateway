module ControllerHelpers
  module AuthHelpers
    def mock_valid_auth_header
      { 'Authorization' => 'Bearer valid-token' }
    end
  end
end

RSpec.configure do |config|
  config.include ControllerHelpers::AuthHelpers, type: :request
end
