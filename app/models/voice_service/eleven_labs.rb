class VoiceService < ApplicationRecord
  class ElevenLabs < VoiceService

    def service_klass
      ElevenLabsService
    end

    def service_name
      "Eleven Labs"
    end

    def generate_voices(hard_reset: false)
      Voice::ElevenLabs.destroy_all if hard_reset

      @voices ||= service.list_voices.map do |voice_config|
        voice = self.voices.find_by(voice_id: voice_config["voice_id"], type: "Voice::ElevenLabs")
        voice ||= self.voices.create!(name: voice_config["name"], voice_id: voice_config["voice_id"], type: "Voice::ElevenLabs", data: voice_config)
        voice
      end
    end
  end
end