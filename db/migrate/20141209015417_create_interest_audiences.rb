class CreateInterestAudiences < ActiveRecord::Migration
  def change
    create_table :interest_audiences do |t|
      t.string    :name
      t.integer   :client_id
      t.integer   :searchengine_id
      t.integer   :audience_id
      t.integer   :keyword_type, :default => 0
      t.string    :campaigns
      t.string    :ad_groups
      t.string    :keywords
      t.string    :genders
      t.string    :age_group
      t.string    :income_group
      t.string    :city_group
      t.text      :result_detail
      t.timestamps
    end
  end
end
