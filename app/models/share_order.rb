class ShareOrder < ActiveRecord::Base
	belongs_to :order

	def self.all_share_orders
		ShareClient.find_by_sql("select s.order_id,group_concat(concat(u.name,' (',a.name,')')) as share_user   from share_orders s left join xmo.users u on s.share_id = u.id
                             left join xmo.agencies a on u.agency_id = a.id group by s.order_id").map{|x| [x.order_id,x['share_user']]}.to_h
	end
end
