class UsersController < ApplicationController
  # Cannot access signup page if already signed in
  before_action :redirect_signed_in_user_to_root, only: %i[ new create ]

  # Only used for handling invites via join codes, Devise handles standard signups
  before_action :set_user, only: :show
  before_action :verify_join_code, only: %i[ new create ]

  def new
    @user = User.new
  end

  def create
    # Finish this up later, need to ensure we revalidate the join code
    # @user = User.create!(user_params)
    # sign in user
    # redirect_to root_url
  rescue ActiveRecord::RecordNotUnique
    redirect_to new_session_url(email: user_params[:email])
  end

  def show
  end

  private
    def set_user
      @user = User.find(params[:id])
    end

    def verify_join_code
      head :not_found if Account.find_by(join_code: params[:join_code]).nil?
    end

    def user_params
      params.require(:user).permit(:first_name, :last_name, :preferred_name, :selected_voice_id, :selected_service_id, :text_size_modifier, :avatar)
    end
end
