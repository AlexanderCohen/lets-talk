class Phrase < ApplicationRecord
  belongs_to :user

  validates :text, presence: true
  validates :category, presence: true

  has_one_attached :audio

  after_create_commit { broadcast_append_to "phrases" }
  after_update_commit { broadcast_replace_to "phrases" }
  after_destroy_commit { broadcast_remove_to "phrases" }

  def audio_url
    if audio.attached?
      Rails.application.routes.url_helpers.rails_blob_url(audio, only_path: false)
    end
  end
end