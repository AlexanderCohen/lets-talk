class CreateVoiceServices < ActiveRecord::Migration[7.0]
  def change
    create_table :voice_services do |t|
      t.string :name, null: false
      t.string :type, null: false

      t.boolean :is_pinned, default: false
      t.boolean :is_hidden, default: false

      t.timestamps
    end
  end
end
