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
    Rails.application.routes.url_helpers.url_for(audio)
  end
end