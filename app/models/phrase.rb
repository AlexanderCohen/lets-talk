class Phrase < ApplicationRecord
  belongs_to :user
  belongs_to :voice, optional: true

  validates :text, presence: true
  validates :category, presence: true

  after_initialize :set_default_category, if: :new_record?

  has_one_attached :audio

  scope :active, -> { where(archived: false) }
  scope :all_including_archived, -> { unscope(where: :archived) }
  scope :archived, -> { unscope(where: :archived).where(archived: true) }

  after_create_commit { broadcast_append_to "phrases" }
  after_update_commit { broadcast_replace_to "phrases" }
  after_destroy_commit { broadcast_remove_to "phrases" }

  def phrase_categories
    user.phrase_categories
  end

  def generate_audio(service)
    audio_content = service.text_to_speech(self.text)
    self.update(voice_id: user.selected_voice.id) unless self.voice_id.eql?(user.selected_voice.id)

    if audio_content.present?
      self.audio.attach(io: StringIO.new(audio_content), filename: "#{SecureRandom.uuid}.mp3", content_type: "audio/mpeg")
    else
      self.errors.add(:base, "Failed to generate audio content")
    end
  end

  def audio_url
    # We can't fetch the url in the same way if using local storage
    return unless audio.attached?

    if Rails.env.production?
      audio.url(expires_in: 3.hours)
    else
      Rails.application.routes.url_helpers.rails_blob_url(audio, only_path: false)
    end
  end

  private

    def set_default_category
      return unless self.category.blank?

      self.category = "Uncategorised"
    end
end
