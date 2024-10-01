module User::VoiceServices
  extend ActiveSupport::Concern

  included do
    store_accessor :config, :selected_voice_id, :selected_service_id, :text_size_modifier
  end

  def voice_service
    if selected_service_id.present?
      @voice_service ||= VoiceService.find_by(id: selected_service_id)
      @voice_service ||= VoiceService.default_service.first # fallback
    else
      @voice_service ||= VoiceService.default_service
    end
  end

  def selected_voice
    if selected_voice_id.present?
      @voice ||= voice_service.voices.find_by(id: selected_voice_id)
      @voice ||= voice_service.fallback_voice
    else
      @voice ||= voice_service.fallback_voice
    end
  end
end
