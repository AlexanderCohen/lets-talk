class User < ApplicationRecord
  include User::VoiceServices, User::Avatar, User::Accessibility, User::Mentionable, User::Auth, User::UserAccounts

  has_many :phrases, dependent: :destroy

  def display_name
    return preferred_name if preferred_name.present?
    return first_name if first_name.present?
    return last_name if last_name.present?

    "Anonymous"
  end

  def name
    name = first_name
    name += " #{last_name}" if last_name.present?
  end

  def phrase_categories
    @phrase_categories ||= phrases.select(:category).distinct.order(:category).pluck(:category)
  end
end
