class Voice < ApplicationRecord
  class ElevenLabs < Voice
    def female?
      gender == "female"
    end

    def male?
      gender == "male"
    end
  end
end
