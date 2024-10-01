class ElevenLabsService
  include HTTParty
  base_uri "https://api.elevenlabs.io"

  # test with ElevenLabsService.new.text_to_speech("Hello, how are you?")
  def initialize
    @api_key = ENV["ELEVEN_LABS_API_KEY"] || Rails.application.credentials.eleven_labs_api_key
    @headers = {
      Accept: "audio/mpeg",
      "Content-Type": "application/json",
      "xi-api-key": "#{@api_key}"
    }
    ## Replace this with your own voice id or just use the default.
    @voice_id = "Wp52orDXakT0vizZyufK"
  end

  def text_to_speech(text)
    body = {
      text: text,
      model_id: "eleven_turbo_v2_5",
      voice_id: @voice_id,
      voice_settings: {
        stability: 0.7,
        similarity_boost: 1.0
      }
    }
    path = "/v1/text-to-speech/#{@voice_id}"
    puts path
    response = self.class.post(path, headers: @headers, body: body.to_json)
    case response.code
    when 200
      # Return the MP3 file content directly
      response.body
    when 429
      Rails.logger.warn "Eleven Labs API rate limit exceeded."
      nil
    else
      Rails.logger.error "Eleven Labs API Error #{response.code}: #{response.message}"
      nil
    end
  rescue => e
    Rails.logger.error "Eleven Labs API Exception: #{e.message}"
    nil
  end
end
