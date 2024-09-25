class ElevenLabsService
    include HTTParty
    base_uri 'https://api.elevenlabs.io'
  
    def initialize
      @headers = {
        "Authorization" => "Bearer #{ENV['ELEVEN_LABS_API_KEY']}",
        "Content-Type" => "application/json"
      }
    end
  
    def text_to_speech(text)
      body = {
        text: text,
        voice: "en-US-Standard-B",
        format: "mp3"
      }
      response = self.class.post('/v1/text-to-speech', headers: @headers, body: body.to_json)
      case response.code
      when 200
        response.parsed_response['audio_url']
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
  end