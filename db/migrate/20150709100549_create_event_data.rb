class CreateEventData < ActiveRecord::Migration
  def change
    Event.create [
                     {name: '客户审批-销售总监',notify_method: 'notify_wait_client_examine',event_type: '客户'},
                     {name: '订单审批-策划',notify_method: 'planner_unapproved',event_type: '订单'},
                     {name: '订单审批-总裁',notify_method: 'sales_president_unapproved',event_type: '订单'},
                     {name: '订单审批-销售总监',notify_method: 'sales_manager_unapproved',event_type: '订单'},
                     {name: '订单审批-排期表审批',notify_method: 'proof_unapproved',event_type: '订单'},
                     {name: '订单审批-媒介部门',notify_method: 'media_assessing_officer_unapproved',event_type: '订单'},
                     {name: '订单审批-产品部门',notify_method: 'product_assessing_officer_unapproved',event_type: '订单'},
                     {name: '订单审批-财务/法务',notify_method: 'legal_officer_unapproved',event_type: '订单'},
                     {name: '订单状态-销售',notify_method: 'notify_sale',event_type: '订单'},
                     {name: '订单审批-销售组长',notify_method: 'notify_team_header',event_type: '订单'},
                     {name: '通知功能组用户',notify_method: 'notify_function_group',event_type: '订单'},
                     {name: '订单审批-运营总监',notify_method: 'notify_operaters_manager',event_type: '订单'},
                     {name: '订单驳回',notify_method: 'notify_approver',event_type: '订单'},
                     {name: '订单分配成功',notify_method: 'notify_operaters_member',event_type: '订单'},
                     {name: '客户被占用',notify_method: 'notify_sale_with_client_same_channel',event_type: '客户'},
                     {name: '客户审批-销售组长',notify_method: 'notify_team_header',event_type: '客户'},
                     {name: '客户审批通过',notify_method: 'notify_client_approved',event_type: '客户'},
                     {name: '客户解锁',notify_method: 'notify_client_share_or_released',event_type: '客户'},
                     {name: '客户权限释放',notify_method: 'notify_client_released',event_type: '客户'},
                     {name: '客户审批驳回',notify_method: 'notify_approver',event_type: '客户'}
                 ]
  end
end
