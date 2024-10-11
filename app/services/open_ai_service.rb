class OpenAiService
  def initialize
    # Configure the OpenAI client with your API key
    OpenAI.configure do |config|
      config.access_token = Rails.application.credentials.openai_api_key
      config.log_errors = true if ENV['RAILS_ENV'] == 'development' # Recommended for development if
    end
    @client = OpenAI::Client.new
  end

  # OpenAiService.new.suggest_phrase_completions("Would you do me the kindness ")
  def suggest_phrase_completions(partial_phrase_to_complete)

    # TODO: Update this to be dynamic to the user later.
    # Hardcoding the background info for now to Michael Cohen.
    background_info ="Background:
     You are phrases to respond to others on behalf of Michael who is 78 years old, he has lost the ability to speak due to motor Neuron disease and lives in Brisbane Australia and has three kids,
     Alex (33), Sophie (30) & Ben (42). His grandkids are called Allegra (8), Henry (4) & James (2). Michael  is charming and charismatic. He is personable and positive in nature. 
     In some limited cases he likes to use metaphor and esoteric conversation style. 
     Do not limit the responses to only metaphor or esoteric language."


    prompt = "Your task is to complete this partial phrase: #{partial_phrase_to_complete}

    your first task is to establish if the phrase is a full sentence or if it short hand for a longer phrase. 
    Once you have established this, you should then complete the phrase. If you are unsure, provide both a partial repsonse and a full response.

    Do not include any other text in your response other than the phrase suggestions.

    Your response should be an array of 4 phrase suggestions.
    [\"phrase1\", \"phrase2\", \"phrase3\", \"phrase4\"]

    Begin each phrase with the current partial phrase to complete: #{partial_phrase_to_complete}.

    #{background_info}
    Take into account the author of the partial phrase may be dyslexic and trying to use phonetic spelling. If this is the case, replace the partial phrase with the correct spelling. 
    Use UK English spelling and grammar. Ensure the phrases are conversational and natural sounding. If you have to, be dumb.
    "
    response = @client.chat(
        parameters: {
            model: "gpt-4o-mini",
        messages: [{ role: "user", content: prompt }]
      }
    )

    # Extract and return the suggestions
    suggestions_string = response.dig("choices").map { |choice| choice.dig("message", "content") }.first
    suggestions_array = JSON.parse(suggestions_string) # Convert the string to an array

    suggestions_array # Return the array of suggestions
  end
end
