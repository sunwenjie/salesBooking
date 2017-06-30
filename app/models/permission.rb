class Permission < ActiveRecord::Base
  belongs_to :node,:inverse_of => :permissions
  belongs_to :user,:inverse_of => :permissions,foreign_key: "approval_user"
  belongs_to :approval_flow

  def self.group_cartesian_product(flow)
      for_create_group = flow.user_group
      for_approval_group = flow.approval_group
      approval_flow_id = flow.id
      node_id = flow.node_id
      model = flow.model
      if self.find_by_approval_flow_id approval_flow_id
        self.delete_all({"approval_flow_id"=> approval_flow_id})
      end
       for_create_users = Group.round_group_users(for_create_group)
       for_approval_users = Group.round_group_users(for_approval_group)
       cartesian_product = for_create_users.product(for_approval_users)
      insert_value = []
       cartesian_product.each do |p|
         insert_value.push "(#{approval_flow_id},#{p[0]},#{p[1]},#{node_id},'#{model}',now(),now())"
       end
      if insert_value.present?
      sql = "INSERT INTO permissions (approval_flow_id,create_user,approval_user,node_id,model,created_at,updated_at) values #{insert_value.join(",")}"
      self.connection.execute(sql)
      end
  end
end
