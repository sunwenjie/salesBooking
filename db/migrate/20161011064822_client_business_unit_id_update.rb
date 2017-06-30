class ClientBusinessUnitIdUpdate < ActiveRecord::Migration
  def change
    clients = Client.where("business_unit_id is null")
    clients.each do |client|
      agency_id = (User.find client.user_id).agency_id  rescue 1
      business_unit_id = BusinessUnit.where({"agency_id" => agency_id }).map(&:id).first
      client.update_columns(:business_unit_id =>business_unit_id.nil? ? 1 : business_unit_id)
    end
  end
end
