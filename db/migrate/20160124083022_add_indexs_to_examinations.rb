class AddIndexsToExaminations < ActiveRecord::Migration
  def change
    add_index :examinations, [:node_id]
    add_index :examinations, [:examinable_id]
  end
end
