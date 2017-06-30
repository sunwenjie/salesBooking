module SendOrderAdvertisementClient
#order 和 client 公用的实例方法


  #当前标签最后一次提交操作信息和最后一次审批信息
  def last_commit_and_approval(node_id)
    p 11112222444

    create_user = "-"
    approval_user = "-"
    create_time = "-"
    approval_time = "-"
    create_group = "-"
    approval_group = "-"
    approval_comment = ""
    last_commit =[]
    last_approval = []
    examiantions = Examination.where({examinable_id: self.id,node_id: node_id}).order("created_at")
    examiantions.each do |value|
      last_commit << value if value.status.to_i == 1
      last_commit << [] if value.status.to_i == 0
      last_approval << value if value.status.to_i >1
    end
    last_commit = last_commit.last
    last_approval =last_approval.last

    if last_commit.present? &&  examiantions.last.status.to_i != 0
      create_user =   last_commit.created_user
      create_time = last_commit.created_at.localtime.strftime("%Y/%m/%d %H:%M")
      create_group = Group.with_groups(create_user).map(&:group_name).join(",") if create_user != "-"
    end
    if  last_approval.present? && examiantions.last.status.to_i > 1
      approval_user =   last_approval.created_user
      approval_time = last_approval.created_at.localtime.strftime("%Y/%m/%d %H:%M")
      p 555555555
      p last_approval.comment.class.to_s
      p last_approval.comment
      approval_comment = last_approval.comment.class.to_s == "String" ? last_approval.comment : last_approval.comment.join(",") if last_approval.comment.present?
      if approval_user.present?
      admin_user = User.find_by(User.user_conditions(approval_user)).present? ? User.find_by(User.user_conditions(approval_user)).administrator? : "-"
      if approval_user != "-" && !admin_user
        user_group_ids = Group.with_groups(approval_user).map(&:id)
        approval_group_ids = ApprovalFlow.all.map(&:approval_group)
        approval_group = Group.where("id" => (user_group_ids & approval_group_ids)).map(&:group_name).join(",")
      elsif admin_user
        approval_group = Group.with_groups(approval_user).map(&:group_name).join(",")
      end
      end
    end
    return create_user,create_group,create_time,approval_user,approval_group,approval_time,approval_comment
  end

  #更新订单的code字段
  def update_order_code
    order = (self.class == Order) ? self : self.order
    new_code = 'OR' + "%09d" % order.id
    order.update_columns({:code=>new_code})
  end

  #更新订单字段:是否为非标订单 是否有地市分配 是否能分配GP GP是否分配完成
  def update_order_columns
    order = (self.class == Order) ? self : self.order
    is_standard = order.order_standard_or_unstandard? ? true : false
    have_admeasure_map = order.order_have_admeasure_map? ? true : false
    is_jast_for_gp =  order.jast_for_gp_advertisement? ? true : false
    order.update_columns(:is_standard=>is_standard,:have_admeasure_map=>have_admeasure_map,:is_jast_for_gp=>is_jast_for_gp,:proof_state=>"1",:is_gp_commit => false)
  end

  def update_orders
    order = (self.class == Order) ? self : self.order
    order.update_last_user_and_last_time(Order.update_user.name) if Order.update_user.present? && Order.update_user.name.present?
    # order.send(:update_without_callbacks)
  end

  #gp,排期表,客户修改后重置订单审批节点 合同审批节点状态
  def change_examination_some_node_status(node_id,current_user)
    p 555555555555
    node_id = node_id || "null"
    examinations = Examination.where({:examinable_id=>self.id,:node_id=> node_id}).order("created_at")
    change_success = false
    if examinations.present?
      item_last = examinations.last
      obj = Examination.new
      obj.approval  = item_last.approval
      obj.comment = item_last.comment
      obj.created_user = current_user.nil? ? "" : current_user.name
      obj.from_state = item_last.from_state
      obj.to_state = item_last.to_state
      obj.examinable_id = item_last.examinable_id
      obj.examinable_type = item_last.examinable_type
      obj.node_id = item_last.node_id
      obj.status = '0'
      obj.created_at = DateTime.now
      obj.message_id = ''
      obj.language = item_last.language
      change_success = true if obj.save
    end
    return change_success
  end


  def change_examinations_status(current_user,examinable_type)
    p 544444444444444
    examinations = Examination.where({:examinable_id=>self.id,:examinable_type=> examinable_type}).order("created_at").group_by(&:node_id)
    change_success = false
    if examinations.present?
      examinations.each do |node_id,items|
        item_last = items.last
        obj = Examination.new
        obj.approval  = item_last.approval
        obj.comment = item_last.comment
        obj.created_user = current_user.name
        obj.from_state = item_last.from_state
        obj.to_state = item_last.to_state
        obj.examinable_id = item_last.examinable_id
        obj.examinable_type = item_last.examinable_type
        obj.node_id = item_last.node_id
        obj.status = '0'
        obj.created_at = DateTime.now
        obj.message_id = ''
        obj.language = item_last.language
        change_success = true if obj.save
      end
    end
    return change_success
  end


  #当前审批流
  def current_flows(node_id)
    share_ids = self.class == Order ? self.share_order_user_ids : self.share_client_user_ids
    Permission.where("node_id in (?) and (create_user = ? or create_user in (?) )",node_id,self.user_id,share_ids).map(&:approval_flow_id).uniq
  end

  #当前订单所在审批流包含的审批组
  def approval_groups(node_id)
    approval_flow_ids = current_flows(node_id)
    approval_flows = ApprovalFlow.where({"id"=>approval_flow_ids})
    if node_id == 3
      #取出当前订单非标审批流所有net gp 区间范围
      gp_range = approval_flows.order(:min,:max).map{|a| [a.id,Range.new(a.min,a.max)]}
      approval_flow_id = []
      gp_range.each do |g|
        if g[1].include? (self.net_gp)
          approval_flow_id.push (g[0])
          break
        end
      end
      approval_flows = ApprovalFlow.find approval_flow_id rescue []
    end
    approval_groups = approval_flows.map(&:approval_group)
    return approval_groups
  end


  #当前非标订单审批流net gp设定为范围的审批流

  def unstandard_range
    approval_flow_ids = current_flows(3)
    approval_flow = ApprovalFlow.where({"id"=>approval_flow_ids,"range_type"=> 'range'}).order(:min,:max).first rescue nil
    if approval_flow
      min,max = approval_flow.min,approval_flow.max
    else
      min,max = nil,nil
    end
    return min.to_f,max.to_f
  end


  #当前订单所在审批流包含的运营am组
  def operation_am_group
    approval_flow_ids = current_flows(5) # 运营分配节点
    approval_flows = ApprovalFlow.where({"id"=>approval_flow_ids})
    operation_am_group = approval_flows.map(&:operation_am_group).flatten
    return operation_am_group
  end

  #运营分配成功之后更新xmo.clientgroups
  def insert_into_clientgroups(client_id,group_ids)
    sql = ActiveRecord::Base.connection()
    agency_ids = Group.where({"id" => group_ids}).map{|group|[group.id.to_s, group.agency_id]}
    group_agency = agency_ids.present? ? agency_ids.flatten.each_slice(2).to_h : {}
    if group_ids.present?
      group_ids.each do |clientgroup|
       client_shared = Client.find_by_sql("select count(*) as num from xmo.clientgroups where client_id = #{client_id} and group_id = #{clientgroup} and group_type = 'SHARED'")
       if client_shared.first["num"] == 0
          sql.insert "insert into xmo.clientgroups(client_id,group_id,created_at,updated_at,group_type) values(#{client_id},#{clientgroup},now(),now(),'SHARED')"
        end
       client_groupshared = Client.find_by_sql("select count(*) as num from xmo.clientgroups where client_id = #{client_id} and group_id = #{clientgroup} and group_type = 'GROUP_SHARED'")
       if client_groupshared.first["num"] == 0
         sql.insert "insert into xmo.clientgroups(client_id,group_id,created_at,updated_at,group_type) values(#{client_id},#{clientgroup},now(),now(),'GROUP_SHARED')"
       end
      end
      sql.update "update xmo.clients set group_ids_extend = '#{group_ids.join(",")}' , manage_option='Share' where id = #{client_id}" if group_agency.present?
    end
  end

  #当前节点最后一次操作状态
  def current_node_last_status(node_id)
    model = (self.class == Order) ? 'Order' : 'Client'
    examinations =  Examination.where({"examinable_id" =>self.id,"node_id"=>node_id,"examinable_type"=>model})
    if examinations.present?
      return examinations.last.status
    end
  end

  #当前节点最后一次提交操作记录
  def node_last_commit_examination(node_id)
    model = (self.class == Order) ? 'Order' : 'Client'
    Examination.where({"examinable_id" =>self.id,"node_id"=>node_id,"examinable_type"=>model,"status"=> '1'}).last rescue nil
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
  module ClassMethods
     def display_item_class(value)
       value.present? ? value : '-'
     end
  end
end