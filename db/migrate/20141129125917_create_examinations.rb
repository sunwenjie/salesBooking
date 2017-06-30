class CreateExaminations < ActiveRecord::Migration
  def change
    create_table :examinations do |t|
      t.integer :approval
      t.text :comment
      t.string :created_user    
      t.string :from_state
      t.string :to_state
      t.string :message_id
      t.references :examinable, polymorphic: true 
      t.datetime :created_at
    end
    add_index :examinations,:message_id
  end
end
