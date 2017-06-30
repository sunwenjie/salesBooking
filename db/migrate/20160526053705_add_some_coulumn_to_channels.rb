class AddSomeCoulumnToChannels < ActiveRecord::Migration
  def change
    add_column :channels, :qualification_name, :string
    add_column :channels, :currency_id, :integer, limit: 11, default: 2
    add_column :channels, :company_adress, :string
    #add_column :channels, :rebate, :decimal, precision: 6, scale: 3
    add_column :channels, :sales, :string
    add_column :channels, :contact_person, :string
    add_column :channels, :phone, :string
    add_column :channels, :email, :string
    add_column :channels, :position, :string
  end
end
