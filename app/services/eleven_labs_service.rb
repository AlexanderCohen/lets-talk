class ElevenLabsService
    include HTTParty
    base_uri 'https://api.elevenlabs.io'

    DEFAULT_VOICE_ID = "Wp52orDXakT0vizZyufK".freeze
  
    # test with ElevenLabsService.new.text_to_speech("Hello, how are you?")
    def initialize(voice_id: DEFAULT_VOICE_ID)
      @api_key = ENV['ELEVEN_LABS_API_KEY'] || Rails.application.credentials.eleven_labs_api_key
      @headers = {
        "Accept": "audio/mpeg", "Content-Type": "application/json", "xi-api-key": "#{@api_key}"
      }

      @voice_id = voice_id
    end

    def api
      Api
    end

  
    def text_to_speech(text)
      body = {
        text: text,
        model_id: "eleven_turbo_v2_5",
        voice_id: @voice_id,
        voice_settings: { stability: 0.7, similarity_boost: 1.0 }
      }
      path = "/v1/text-to-speech/#{@voice_id}"

      response = self.class.post(path, headers: @headers, body: body.to_json)
      case response.code
      when 200
        response.body # Return the MP3 file content directly
      when 429
        Rails.logger.warn "Eleven Labs API rate limit exceeded."
        nil
      else
        Rails.logger.error "Eleven Labs API Error #{response.code}: #{response.message}"
        nil
      end
    rescue StandardError => e
      Rails.logger.error "Eleven Labs API Exception: #{e.message}"
      nil
    end

    def list_voices
      path = "/v1/voices"
      response = self.class.get(path, headers: @headers)
      parsed_voices = JSON.parse(response.body) || {}
      parsed_voices.dig("voices")
    rescue JSON::ParserError => e
      Rails.logger.error "Eleven Labs API Error #{e.message}"
      []
    end
  end