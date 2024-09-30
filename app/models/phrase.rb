class Phrase < ApplicationRecord
  belongs_to :user

  validates :text, presence: true
  validates :category, presence: true

  has_one_attached :audio

  # default_scope { where(archived: false) }
  scope :active, -> { where(archived: false) }
  scope :all_including_archived, -> { unscope(where: :archived) }
  scope :archived, -> { unscope(where: :archived).where(archived: true) }

  after_create_commit { broadcast_append_to "phrases" }
  after_update_commit { broadcast_replace_to "phrases" }
  after_destroy_commit { broadcast_remove_to "phrases" }

  def audio_url
    if audio.attached?
      if Rails.env.production?
        audio.url(expires_in: 3.hours)
      else
        Rails.application.routes.url_helpers.rails_blob_url(audio, only_path: false)
      end
    end
  end
end