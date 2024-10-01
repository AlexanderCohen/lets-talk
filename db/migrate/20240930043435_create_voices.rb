class CreateVoices < ActiveRecord::Migration[7.0]
  # rails db:migrate:up VERSION=20240930043435
  def up
    create_table :voices do |t|
      t.belongs_to :voice_service, null: false, foreign_key: true

      t.string :voice_id, null: false
      t.string :name, null: false
      t.string :type, null: false
      t.string :language, null: false
      
      t.jsonb :data, null: false, default: {}

      t.string :gender
      t.string :nationality
      t.text :description

      t.timestamps
    end

    add_index :voices, [:voice_id, :type], unique: true

    Rails.logger.info "Running VoiceService.setup"
    VoiceService.setup
  end

  # rails db:migrate:down VERSION=20240930043435
  def down
    drop_table :voices
  end
end
