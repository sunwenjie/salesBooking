class CreateProvinces < ActiveRecord::Migration
  def change
    create_table :provinces do |t|
      t.string   :code_id
      t.string    :name
      t.string    :name_cn
      t.timestamps
    end
  end
end
