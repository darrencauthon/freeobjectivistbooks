class CreateReminderEntities < ActiveRecord::Migration
  def change
    create_table :reminder_entities do |t|
      t.references :reminder
      t.references :entity
      t.string :entity_type

      t.timestamps
    end
    add_index :reminder_entities, :reminder_id
    add_index :reminder_entities, :entity_id
    add_index :reminder_entities, :entity_type
  end
end
