class AddNodeIdStatusToExaminations < ActiveRecord::Migration
  def change
    add_column :examinations, :node_id, :integer
    add_column :examinations, :status, :string
  end
end
