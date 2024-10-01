class AddCurrentAccountIdToUser < ActiveRecord::Migration[7.2]
  # rails db:migrate:up VERSION=20241001084347
  def up
    add_column :users, :current_account_id, :bigint
    add_column :phrases, :voice_id, :bigint
  end

  # rails db:migrate:down VERSION=20241001084347
  def down
    remove_column :users, :current_account_id
    remove_column :phrases, :voice_id
  end
end
