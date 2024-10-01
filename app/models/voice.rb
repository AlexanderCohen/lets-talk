class Voice < ApplicationRecord
  belongs_to :voice_service, class_name: "VoiceService"

  has_one_attached :audio_sample

  before_validation :set_type
  before_validation :set_language
  before_validation :set_gender

  after_create_commit :generate_audio_sample

  def audio_sample_url
    # We can't fetch the url in the same way if using local storage
    return unless audio_sample.attached?

    if Rails.env.production?
      audio_sample.url(expires_in: 3.hours)
    else
      Rails.application.routes.url_helpers.rails_blob_url(audio_sample, only_path: false)
    end
  end

  # private

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

    def generate_audio_sample
      return if audio_sample.attached?

      sample_text = "Hello, how are you today?"
      sample_text += " My name is #{name}" if name.present?

      audio_sample_content = voice_service.service_klass.new(voice_id: self.voice_id).text_to_speech(sample_text)

      if audio_sample_content.present?
        self.audio_sample.attach(io: StringIO.new(audio_sample_content), filename: "voice_#{voice_id}_#{SecureRandom.uuid}.mp3", content_type: "audio/mpeg")
      else
        Rails.logger.error "Failed to generate audio sample content"
      end
    end
    
end
