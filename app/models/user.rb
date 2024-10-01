class User < ApplicationRecord
  include User::VoiceServices, User::Avatar, User::Accessibility, User::Mentionable, User::Auth

  has_many :phrases, dependent: :destroy

  def display_name
    return preferred_name if preferred_name.present?
    return first_name if first_name.present?
    return last_name if last_name.present?

    "Anonymous"
  end

  def phrase_categories
    @phrase_categories ||= phrases.select(:category).distinct.order(:category).pluck(:category)
  end
end
