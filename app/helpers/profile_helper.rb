module ProfileHelper
  def current_voice_service
    current_user.voice_service
  end

  def current_voice
    current_user.selected_voice
  end

  def voice_service_options
    VoiceService.pluck('voice_services.name', 'voice_services.id')
  end
end
