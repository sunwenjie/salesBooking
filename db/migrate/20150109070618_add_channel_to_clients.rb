class AddChannelToClients < ActiveRecord::Migration
  def change
    add_column :clients, :whether_channel, :boolean
    add_column :clients, :channel, :string
  end
end
