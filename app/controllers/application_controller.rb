class ApplicationController < ActionController::Base
  include SetCurrentRequest, SetPlatform

  before_action :authenticate_user!

  def current_users_voice_service
    return unless current_user.present?

    @current_users_voice_service ||= current_user.voice_service.service
  end

  def redirect_signed_in_user_to_root
    redirect_to root_url if signed_in?
  end
end
