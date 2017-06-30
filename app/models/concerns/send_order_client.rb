module Concerns
  #order 和 client 公用的实例方法

  module SendOrderClient

    #当前标签最后一次提交操作信息和最后一次审批信息
    def last_commit_and_approval(node_id)
      create_user = '-'
      approval_user = '-'
      create_time = '-'
      approval_time = '-'
      approval_comment = ''
      last_commit =[]
      last_approval = []
      examiantions =  self.all_examinations_by_node(node_id)
      examiantions.each do |value|
        last_commit << value if value.status.to_i == 1
        last_commit << [] if value.status.to_i == 0
        last_approval << value if value.status.to_i >1
      end
      last_commit = last_commit.last
      last_approval =last_approval.last

      if last_commit.present? && examiantions.last.status.to_i != 0
        create_user = last_commit.created_user
        create_time = last_commit.created_at.localtime.strftime("%Y/%m/%d %H:%M")
      end
      if last_approval.present? && examiantions.last.status.to_i > 1
        approval_user = last_approval.created_user
        approval_time = last_approval.created_at.localtime.strftime("%Y/%m/%d %H:%M")
        approval_comment = last_approval.comment.class.to_s == "String" ? last_approval.comment : last_approval.comment.join(",") if last_approval.comment.present?
      end
      return create_user, create_time, approval_user, approval_time, approval_comment
    end

    #更新订单字段:是否为非标订单 是否有地市分配 是否能分配GP GP是否分配完成
    def update_order_columns
      order = (self.class == Order) ? self : self.order
      is_standard = order.order_standard_or_unstandard? ? true : false
      have_admeasure_map = order.order_have_admeasure_map? ? true : false
      is_jast_for_gp = order.jast_for_gp_advertisement? ? true : false
      order.update_columns(:is_standard => is_standard, :have_admeasure_map => have_admeasure_map, :is_jast_for_gp => is_jast_for_gp, :proof_state => '1', :is_gp_commit => false)
    end

    def update_orders
      order = (self.class == Order) ? self : self.order
      order.update_last_user_and_last_time(Order.update_user.name) if Order.update_user.present? && Order.update_user.name.present?
    end

    #重置部分节点操作状态
    def change_examination_some_node_status(node_id, current_user)
      node_id = node_id || 'null'
      last_examination =  self.last_examination_by_node(node_id)
      return last_examination && last_examination.examination_dup(current_user)
    end

    def change_examinations_status(current_user)
      self.examinations.each{|examination| examination.examination_dup(current_user)}
    end

    #当前审批流
    def current_flows(node_id)
      share_ids = self.class == Order ? self.share_order_user_ids : self.share_client_user_ids
      Permission.where('node_id in (?) and (create_user = ? or create_user in (?) )', node_id, self.user_id, share_ids).map(&:approval_flow_id).uniq
    end

    #当前订单所在审批流包含的审批组
    def approval_groups(node_id)
      approval_flow_ids = current_flows(node_id)
      approval_flows = ApprovalFlow.where({"id" => approval_flow_ids})
      if node_id == 3
        #取出当前订单非标审批流所有net gp 区间范围
        gp_range = approval_flows.order(:min, :max).map { |a| [a.id, Range.new(a.min, a.max)] }
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

    #节点所有操作记录
    def all_examinations_by_node(node_id)
      self.examinations.find_examinations_by_node(node_id)
    end

    #节点最后一次操作记录
    def last_examination_by_node(node_id)
      all_examinations_by_node(node_id).last
    end

    #当前节点最后一次操作状态
    def current_node_last_status(node_id)
      last_examination_by_node(node_id).status rescue ''
    end

    #当前节点最后一次提交操作记录
    def last_examination_commit(node_id)
      all_examinations_by_node(node_id).where(status: '1').last
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
end