class AddUpdateClientState < ActiveRecord::Migration
  def change
    execute "update xmo.clients set state = 'cli_saved' where state is null"
  end
end
