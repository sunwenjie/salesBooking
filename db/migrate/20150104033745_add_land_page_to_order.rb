class AddLandPageToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :landing_page, :string
    add_column :orders, :frequency_limit, :boolean
    add_column :orders, :frequency,:string
    add_column :orders, :keywords, :text
    add_column :orders, :whether_monitor, :boolean
    add_column :orders, :third_monitor,:string
    add_column :orders, :xmo_code, :boolean
    add_column :orders, :client_material, :boolean
    add_column :orders, :report_template, :string
    add_column :orders, :report_period, :string
  end
end
