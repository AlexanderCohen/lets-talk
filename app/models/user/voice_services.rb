module User::VoiceServices
  extend ActiveSupport::Concern

  included do
    store_accessor :config, :selected_voice_id, :selected_service_id, :text_size_modifier
  end

  def voice_service
    if selected_service_id.present?
      @voice_service ||= VoiceService.find(selected_service_id)
    else
      @voice_service ||= VoiceService.default_service.first
    end
  end

  def selected_voice
    if selected_voice_id.present?
      @voice ||= voice_service.voices.find(selected_voice_id)
    else
      @voice ||= voice_service.voices.first
    end
  end
end
