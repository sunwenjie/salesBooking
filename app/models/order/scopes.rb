class Order < Base

  include Concerns::Extract

  include Concerns::Condition

  def self.simple_scopes
    [
        :ascend_by_updated_at,
        :descend_by_updated_at,
        :ascend_by_code,
        :descend_by_code,
        :ascend_by_state,
        :descend_by_state
    ]
  end

  add_simple_scopes simple_scopes

  add_search_scope :not_deleted do
    where("#{Order.quoted_table_name}.deleted_at IS NULL or #{Order.quoted_table_name}.deleted_at >= ?", Time.zone.now)
  end

  %w{id code}.each do |_|
    eval %Q(
          add_search_scope :with_#{_}s do |*#{_}s|
            where(#{_}: #{_}s)
          end
       )
  end

  add_search_scope :with_orders do |user, date|
    range_condition = date_range_condition(date)
    user = User.find_by(user_conditions(user))
    #user = User.find 1026
    return if user.nil?
    if user.administrator?
      find_by_sql("select m.* from (select o.id,o.code,o.title,o.start_date,o.ending_date,o.user_id,o.budget,o.budget_currency,o.city,o.created_at,o.updated_at,o.regional,o.gp_commit_user,o.gp_commit_time,o.schedule_commit_user,o.schedule_commit_time,o.is_standard,o.have_admeasure_map,o.is_jast_for_gp,o.is_gp_finish,o.new_regions,o.last_update_user,o.last_update_time,o.is_gp_commit,o.whether_service,o.state,
                 o.proof_state,o.third_monitor,'1,2,3,4,5,7' as node_ids,ifnull(t2.status,'0,0,0,0,0,0') as status,
                 c.id as client_id,c.clientname as client_name,c.created_user as client_user,u.id as userid,indu.id as instrucy_id,channel.id as channel_id,channel.channel_name
                  from orders o
                  left join
                  ( select t.examinable_id,group_concat(t.statu order by t.node_id asc) as status from (select s.num as node_id,s.examinable_id,max(s.status) as statu from
                  (select n.num,f.examinable_id,f.node_id,
                   case when n.num = f.node_id then f.status
                   when n.num <> f.node_id then  0
                  end as status
                  from
                  ( select 1 as num,'flag' as flag from dual
                  union all
                  select 2 as num,'flag' as flag from dual
                  union all
                  select 3 as num,'flag' as flag from dual
                  union all
                  select 4 as num,'flag' as flag from dual
                  union all
                  select 5 as num,'flag' as flag from dual
                  union all
                  select 7 as num,'flag' as flag from dual
                  ) n ,
                  (select e.examinable_id,e.node_id,e.status,'flag' as flag
                  from examinations e,
                  (select max(e.created_at)  as created_at from examinations e where e.examinable_type = 'Order'
                  group by e.examinable_id,e.node_id order by null)  m where e.created_at = m.created_at and e.status is not null ) f where n.flag = f.flag ) s group by s.num,s.examinable_id order by null) t
                  group by t.examinable_id order by null) t2 on o.id = t2.examinable_id
                  left join xmo.clients c on o.client_id = c.id
                  left join xmo.users u on o.user_id = u.id
                  left join industries indu on o.industry_id = indu.id
                  left join channels channel on o.channel_id = channel.id
                  where o.deleted_at is null) m #{range_condition}
                  order by m.last_update_time desc
                ")

    else
      client_id = Client.with_sale_clients(user, nil, 'all').map(&:id)
      user_id = user.id
      order_id = ShareOrder.where("share_id = ?", user.id).map(&:order_id)
      client_id = client_id.flatten.uniq.present? ? client_id.flatten.uniq.join(",") : 'NULL'
      order_id = order_id.flatten.uniq.present? ? order_id.flatten.uniq.join(",") : 'NULL'
      operator_orders = Order.where({"operator_id" => user.id}).map(&:id)
      share_ams = Operation.where({"id" => ShareAm.where({"user_id" => user.id}).map(&:operation_id)}).map(&:order_id)
      operator_and_share_ams = (operator_orders + share_ams).present? ? (operator_orders + share_ams).uniq.join(",") : "NULL"
      # operator_orders = Order.where("operator = ? ",user.name).map(&:id).present? ? Order.where("operator = ? ",user.name).map(&:id).join(',') : 'NULL'
      find_by_sql("select m.* from ( select t2.id,t2.code,t2.title,t2.start_date,t2.ending_date,t2.user_id,t2.budget,t2.budget_currency,t2.city,t2.created_at,t2.updated_at,t2.regional,t2.gp_commit_user,t2.gp_commit_time,t2.schedule_commit_user,t2.schedule_commit_time,t2.is_standard,t2.have_admeasure_map,t2.is_jast_for_gp,t2.is_gp_finish,t2.new_regions,t2.last_update_user,t2.last_update_time,t2.is_gp_commit,t2.whether_service,t2.state,
t2.proof_state,t2.third_monitor,ifnull(t2.node_ids,'') as node_ids,ifnull(t3.status,'0,0,0,0,0,0') as status,c.id as client_id,c.clientname as client_name,c.created_user as client_user,u.id as userid,indu.id as instrucy_id,channel.id as channel_id,channel.channel_name from
(select t.id,t.code,t.title,t.start_date,t.ending_date,t.user_id,t.budget,t.budget_currency,t.city,t.created_at,t.updated_at,t.regional,t.gp_commit_user,t.gp_commit_time,t.schedule_commit_user,t.schedule_commit_time,t.is_standard,t.have_admeasure_map,t.is_jast_for_gp,t.is_gp_finish,t.new_regions,t.last_update_user,t.last_update_time,t.is_gp_commit,t.whether_service,t.state,t.proof_state,t.third_monitor,t.client_id,t.industry_id,t.channel_id, group_concat(t.node_id order by t.node_id asc) as node_ids from
(select k.* from (select o.*,p.node_id
 from  (select orders.*,share_orders.share_id from orders left join share_orders on orders.id = share_orders.order_id) o
left join advertisements ad on o.id = ad.order_id
left join (select * from  permissions where approval_user = '#{user_id}' and model = 'Order') p on (o.user_id = p.create_user or o.share_id=p.create_user)
left join approval_flows flow on p.approval_flow_id = flow.id
left join approval_flow_ads flow_ad on  flow.id= flow_ad.approval_flow_id
where
((flow.node_id = 2 or flow.node_id  = 3 or flow.node_id  = 4)
 or ad.ad_type = flow_ad.ad_type) or flow_ad.ad_type ='ALL'
 or o.whether_service = 1
 and p.node_id is not null
 and p.node_id not in(10,11,12,13)
) k
 where k.deleted_at is null
 union all
 select  orders.*,'' as share_id, '' as node_id FROM orders
   left  outer join xmo.clients on clients.id = orders.client_id and clients.deleted_at is null
   where orders.deleted_at is null
   and (clients.id in (#{client_id})
   or orders.user_id = #{user_id} or orders.id in (#{order_id})
   or orders.id in (#{operator_and_share_ams}) )
  ) t group by t.id,t.code,t.title,t.start_date,t.ending_date,t.user_id,t.budget,t.budget_currency,t.city,t.created_at,t.updated_at,t.regional,t.gp_commit_user,t.gp_commit_time,t.schedule_commit_user,t.schedule_commit_time,t.is_standard,t.have_admeasure_map,t.is_jast_for_gp,t.is_gp_finish,t.new_regions,t.last_update_user,t.last_update_time,t.is_gp_commit,t.whether_service,t.state,t.proof_state,t.third_monitor,t.client_id,t.industry_id,t.channel_id) t2
  left join
 ( select t4.examinable_id,group_concat(t4.statu order by t4.node_id asc) as status from (select s.num as node_id,s.examinable_id,max(s.status) as statu from
 (select n.num,f.examinable_id,f.node_id,
 case when n.num = f.node_id then f.status
        when n.num <> f.node_id then 0
 end as status
  from
( select 1 as num,'flag' as flag from dual
 union all
  select 2 as num,'flag' as flag from dual
 union all
select 3 as num,'flag' as flag from dual
 union all
select 4 as num,'flag' as flag from dual
 union all
select 5 as num,'flag' as flag from dual
 union all
select 7 as num,'flag' as flag from dual
) n ,
(select e.examinable_id,e.node_id,e.status,'flag' as flag

 from examinations e,
(select max(e.created_at)  as created_at from examinations e where e.examinable_type = 'Order'
 group by e.examinable_id,e.node_id order by null)  m where e.created_at = m.created_at) f where n.flag = f.flag ) s group by s.num,s.examinable_id order by null) t4 group by t4.examinable_id order by null) t3 on t2.id = t3.examinable_id
 left join xmo.clients c on t2.client_id = c.id
 left join xmo.users u on t2.user_id = u.id
 left join industries indu on t2.industry_id = indu.id
 left join channels channel on t2.channel_id = channel.id ) m
 #{range_condition}
 order by m.last_update_time desc

  ")
    end
  end


  add_search_scope :with_current_order do |user, order_id|
    user = User.find_by(user_conditions(user))
    # user = User.find 1484
    return if user.nil?
    if user.administrator?
      find_by_sql("select o.*,'1,2,3,4,5,7' as node_ids,ifnull(t1.status,'0,0,0,0,0,0') as status from orders o left join
                   (select t.examinable_id,group_concat(t.statu order by t.node_id asc) as status from (select s.num as node_id,s.examinable_id,max(s.status) as statu from
                   (select n.num,f.examinable_id,f.node_id,
                   case when n.num = f.node_id then f.status
                   when n.num <> f.node_id then  0
                   end as status
                   from
                   ( select 1 as num,'flag' as flag from dual
                   union all
                   select 2 as num,'flag' as flag from dual
                   union all
                   select 3 as num,'flag' as flag from dual
                   union all
                   select 4 as num,'flag' as flag from dual
                   union all
                   select 5 as num,'flag' as flag from dual
                   union all
                   select 7 as num,'flag' as flag from dual
                   ) n ,
                   (select e.examinable_id,e.node_id,e.status,'flag' as flag
                   from examinations e,
                   (select max(e.created_at)  as created_at from examinations e where e.examinable_type = 'Order' and e.examinable_id = #{order_id}
                   group by e.examinable_id,e.node_id)  m where e.created_at = m.created_at and e.status is not null ) f
                   where n.flag = f.flag ) s group by s.num,s.examinable_id) t group by t.examinable_id ) t1 on o.id = t1.examinable_id where o.id = #{order_id}")
    else
      find_by_sql("select orders.*,t1.node_ids,ifnull(t2.status,'0,0,0,0,0,0') as status from orders  left join
                   (select o.id,group_concat(p.node_id order by p.node_id asc) as node_ids
                   from ((select orders.*,share_orders.share_id from orders left join share_orders on orders.id = share_orders.order_id)) o

                   left join advertisements ad on o.id = ad.order_id
                   left join (select * from  permissions where approval_user = '#{user.id}' and model = 'Order') p on (o.user_id = p.create_user or o.share_id=p.create_user)
                   left join approval_flows flow on p.approval_flow_id = flow.id
                   left join approval_flow_ads flow_ad on  flow.id= flow_ad.approval_flow_id
                   where ((flow.node_id = 2 or flow.node_id  = 3 or flow.node_id  = 4)
                   or ad.ad_type = flow_ad.ad_type) or flow_ad.ad_type ='ALL'
                   or o.whether_service = 1
                   and p.node_id is not null
                   and p.node_id not in(10,11,12,13)
                   and o.id = '#{order_id}' group by o.id) t1 on orders.id = t1.id
                   left join
                   (select t.examinable_id,group_concat(t.statu order by t.node_id asc) as status from (select s.num as node_id,s.examinable_id,max(s.status) as statu from
                   (select n.num,f.examinable_id,f.node_id,
                   case when n.num = f.node_id then f.status
                   when n.num <> f.node_id then  0
                   end as status
                   from
                   ( select 1 as num,'flag' as flag from dual
                   union all
                   select 2 as num,'flag' as flag from dual
                   union all
                   select 3 as num,'flag' as flag from dual
                   union all
                   select 4 as num,'flag' as flag from dual
                   union all
                   select 5 as num,'flag' as flag from dual
                   union all
                   select 7 as num,'flag' as flag from dual
                   ) n ,
                   (select e.examinable_id,e.node_id,e.status,'flag' as flag
                   from examinations e,
                   (select max(e.created_at)  as created_at from examinations e where e.examinable_type = 'Order' and e.examinable_id = #{order_id}
                   group by e.examinable_id,e.node_id)  m where e.created_at = m.created_at and e.status is not null ) f where n.flag = f.flag ) s group by s.num,s.examinable_id) t group by t.examinable_id ) t2 on orders.id = t2.examinable_id where orders.id = #{order_id}")
    end
  end

  # n个组里的user所创建的订单
  add_search_scope :with_groups do |*groups|
    Order.where("user_id in (?)", User.with_groups(groups))
  end

  add_search_scope :by_message do |message_id|
    joins("left outer join #{SendMenu::DbConnection}.examinations on orders.id = #{SendMenu::DbConnection}.examinations.examinable_id").where("#{Examination.table_name}.message_id = ? and #{Examination.table_name}.examinable_type = ?", message_id, 'Order')
  end


end