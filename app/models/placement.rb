# encoding: utf-8
class Placement < ActiveRecord::Base
  establish_connection 'xmo_production'
  has_one :pv_detail
  has_many :pv_deal
end

