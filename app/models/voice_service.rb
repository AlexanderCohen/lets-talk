class VoiceService < ApplicationRecord
  after_initialize :set_type

  has_many :voices, dependent: :destroy

  SERVICE_MAP = {
    eleven_labs: { name: "Eleven Labs", sti_klass: ElevenLabs }
  }.freeze

  def self.setup
    eleven_labs = VoiceService::ElevenLabs.find_or_create_by!(name: "Eleven Labs", is_pinned: true)
    eleven_labs.generate_voices
  end

  def self.valid_services
    SERVICE_MAP.map { |key, value| value[:name] }
  end

  def self.default_service
    VoiceService::ElevenLabs
  end

  def service_klass
    raise "Abstract: Not implemented"
  end

  def service_name
    raise "Abstract: Not implemented"
  end

  def service
    @service ||= service_klass.new
  end

  private

  def set_type
    self.type ||= self.class.default_service.to_s
  end
end
