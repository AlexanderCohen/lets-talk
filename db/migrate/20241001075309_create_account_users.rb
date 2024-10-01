class CreateAccountUsers < ActiveRecord::Migration[7.2]
  # rails db:migrate:up VERSION=20241001075309
  def up
    create_table :account_users do |t|
      t.belongs_to :account, null: false, foreign_key: true
      t.belongs_to :user, null: false, foreign_key: true

      t.boolean :account_admin, null: false, default: false

      t.jsonb :roles, null: false, default: {}

      t.timestamps
    end
  end

  # rails db:migrate:down VERSION=20241001075309
  def down
    drop_table :account_users
  end
end
