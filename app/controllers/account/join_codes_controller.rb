class Account::JoinCodesController < ApplicationController
  before_action :authenticate_user!

  def create
    Current.account.reset_join_code
    redirect_to settings_profile_index_path
  end
end
