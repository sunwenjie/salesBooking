class ClientAttributeValue < ActiveRecord::Base
  belongs_to :client,inverse_of: :client_attribute_values
  belongs_to :sync_attribute,inverse_of: :client_attribute_values
  #serialize :value

  def self.get_sap_clients(client_ids)
    if client_ids.present?
      self.find_by_sql("select
         t.client_id,
        max(t.sap_client) as 'sap_client',
        max(t.client_business_licence_name) as 'client_business_licence_name'
        from
        (select client_id,case when attribute_en_name ='sap_client' then value else '' end as 'sap_client',
        case when attribute_en_name ='client_business_licence_name' then value else '' end as 'client_business_licence_name'
        from client_attribute_values where client_id in (#{client_ids.join(",")}) and attribute_en_name in ('sap_client','client_business_licence_name')) t
        group by t.client_id")
    end
  end

  def self.get_advertisement_masters(client_ids)
    if client_ids.present?
      self.find_by_sql("select
         t.client_id,
        max(t.advertisement_master_id) as 'advertisement_master_id',
        max(t.advertisement_master_name) as 'advertisement_master_name'
        from
        (select client_id,case when attribute_en_name ='advertisement_master_id' then value else '' end as 'advertisement_master_id',
        case when attribute_en_name ='advertisement_master_name' then value else '' end as 'advertisement_master_name'
        from client_attribute_values where client_id in (#{client_ids.join(",")}) and attribute_en_name in ('advertisement_master_id','advertisement_master_name')) t
        group by t.client_id")
    end
  end

end
