class AddNoticeTypeToEvents < ActiveRecord::Migration
  def change
    add_column :events, :notify_type, :string,default: "absolute"
  end
end
