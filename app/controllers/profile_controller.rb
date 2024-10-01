class ProfileController < ApplicationController
  before_action :authenticate_user!

  def settings
  end

  def update
    current_user.update(user_params)
    redirect_to settings_profile_index_path, notice: "Profile updated"
  end

  private

  def user_params
    params.permit(:first_name, :last_name, :preferred_name, :selected_voice_id, :selected_service_id, :text_size_modifier)
  end
end
