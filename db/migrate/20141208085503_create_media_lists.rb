class CreateMediaLists < ActiveRecord::Migration
  def change
    create_table :media_lists do |t|
      t.string :media_category
      t.string :website
      t.string :weburl
      t.string :webtype
      t.string :website_en
      t.datetime :created_at
    end
  end
end
