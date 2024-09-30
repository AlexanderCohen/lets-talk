class Voice < ApplicationRecord
  belongs_to :voice_service, class_name: "VoiceService"

  before_validation :set_type
  before_validation :set_language
  before_validation :set_gender

  private

  def set_type
    return if voice_service.blank?

    self.type = "Voice::#{voice_service.type.split("::").last}"
  end

  def set_language
    return if language.present?

    self.language = data.dig("fine_tuning", "language") || "en"
  end

  def set_gender
    return if gender.present?

    self.gender = data.dig("labels", "gender")
  end
end
