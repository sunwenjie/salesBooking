class ShareClient < ActiveRecord::Base
  belongs_to :client,inverse_of: :share_clients
  def self.all_share_clients
    ShareClient.find_by_sql("select s.client_id,group_concat(concat(u.name,' (',a.name,')')) as share_user   from share_clients s left join xmo.users u on s.share_id = u.id
                             left join xmo.agencies a on u.agency_id = a.id group by s.client_id").map{|x| [x.client_id,x['share_user']]}.to_h
  end
end
