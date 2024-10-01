module SetCurrentRequest
  extend ActiveSupport::Concern

  included do |base|
    if base < ActionController::Base
      before_action :set_request_details
    end
  end
  
  def set_request_details
    Current.request_id = request.uuid
    Current.user_agent = request.user_agent
    Current.ip_address = request.ip
    Current.user = current_user
  end
end
