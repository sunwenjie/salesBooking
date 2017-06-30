class MigrateClientsToXmo < ActiveRecord::Migration
  def change
    execute "alter table xmo.clients add code varchar(255);"
    execute "alter table xmo.clients add state varchar(255);"
    execute "alter table xmo.clients add (created_user varchar(255), deleted_at datetime, sync_flag int(11), sync_time datetime); "
  end
end
