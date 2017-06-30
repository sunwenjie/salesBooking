class SyncAttribute < ActiveRecord::Base
  has_many :order_attribute_values, inverse_of: :sync_attribute
  has_many :client_attribute_values, inverse_of: :sync_attribute
  has_many :channel_attribute_values, inverse_of: :sync_attribute
end
