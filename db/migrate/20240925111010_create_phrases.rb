class CreatePhrases < ActiveRecord::Migration[7.0]
  def change
    create_table :phrases do |t|
      t.references :user, null: false, foreign_key: true
      t.string :text
      t.string :category
      t.string :audio_url

      t.timestamps
    end
  end
end
