# app/controllers/api/base_controller.rb
module Api
  class BaseController < ApplicationController
    before_action :authenticate_request
    
    private
    
    def authenticate_request
      @current_user = request.env['current_user']
      render json: { error: 'Not Authorized' }, status: 401 unless @current_user
    end
    
    def current_user
      @current_user
    end
    
    def authorize!(action, resource = nil)
      unless Auth::Authorizer.can?(current_user, action, resource)
        render json: { error: 'Forbidden' }, status: :forbidden
      end
    end
  end
end
