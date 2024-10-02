class AddConfigToUser < ActiveRecord::Migration[7.0]
  # rails db:migrate:up VERSION=20240930034532
  def up
    add_column :users, :config, :jsonb, default: {}
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :preferred_name, :string

    remove_column :phrases, :audio_url
  end

  # rails db:migrate:down VERSION=20240930034532
  def down
    remove_column :users, :config
    add_column :phrases, :audio_url, :string

    remove_column :users, :first_name
    remove_column :users, :last_name
    remove_column :users, :preferred_name
  end
end
