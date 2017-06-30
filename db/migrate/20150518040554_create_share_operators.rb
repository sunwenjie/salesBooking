class CreateShareOperators < ActiveRecord::Migration
  def change
    create_table :share_operaters do |t|
      t.string   :operater_name
      t.string   :share_name
      t.timestamps
    end
  end
end
