class ProfileController < ApplicationController
  before_action :authenticate_user!

  def settings
  end

  def update
    current_user.update(user_params)
    redirect_to settings_profile_index_path, notice: "Voice service updated"
  end

  private

  def user_params
    params.permit(:selected_voice_id, :selected_service_id)
  end
end
