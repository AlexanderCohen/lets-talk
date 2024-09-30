class AddConfigToUser < ActiveRecord::Migration[7.2]
  # rails db:migrate:up VERSION=20240930034532
  def up
    add_column :users, :config, :jsonb, default: {}
    remove_column :phrases, :audio_url
  end

  # rails db:migrate:down VERSION=20240930034532
  def down
    remove_column :users, :config
    add_column :phrases, :audio_url, :string
  end
end
