module User::UserConfig
  extend ActiveSupport::Concern

  included do
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

    store_accessor :config, :selected_voice_id, :selected_service_id
  end

  def voice_service
    if selected_service_id.present?
      @voice_service ||= VoiceService.find(selected_service_id)
    else
      @voice_service ||= VoiceService.default_service.first
    end
  end

  def voice
    if selected_voice_id.present?
      @voice ||= voice_service.voices.find(selected_voice_id)
    else
      @voice ||= voice_service.voices.first
    end
  end
end
