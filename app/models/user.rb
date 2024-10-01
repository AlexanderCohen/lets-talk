class User < ApplicationRecord
  include User::VoiceServices, User::Avatar, User::Accessibility, User::Mentionable, User::Auth

  has_many :phrases, dependent: :destroy

  def phrase_categories
    @phrase_categories ||= phrases.select(:category).distinct.order(:category).pluck(:category)
  end
end
