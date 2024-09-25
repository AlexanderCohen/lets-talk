class DashboardController < ApplicationController
  def index
    @recent_phrases = current_user.phrases.order(created_at: :desc).limit(5)
  end
end
