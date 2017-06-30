class AddIndustryIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :industry_id, :integer

    Client.all.each do |c|
      code =  Client.create_sn if !code.present?
       c.update_columns({:code=>code})
    end

  end
end
