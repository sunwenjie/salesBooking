class AddRolesDataToEvent < ActiveRecord::Migration
  def change
    Event.all.each{|event|
      notify_method=event.notify_method

      if notify_method=="notify_wait_client_examine"
        event.roles=["sales_manager","sales_president"]
      elsif notify_method=="notify_sale_with_client_same_channel"
        event.roles=["sale","team_head"]
      elsif notify_method=="notify_team_header"
        event.roles=["team_head"]
      elsif notify_method=="notify_client_approved"
        event.roles=["sale"]
      elsif notify_method=="notify_client_share_or_released"
        event.roles=["sale"]
      elsif notify_method=="notify_client_released"
        event.roles=["sale"]
      elsif notify_method=="notify_approver"
        event.roles=["sale"]

      elsif notify_method=="planner_unapproved"
        event.roles=["planner"]

      elsif notify_method=="sales_president_unapproved"
        event.roles=["sales_president"]

      elsif notify_method=="sales_manager_unapproved"
        event.roles=["sales_manager"]

      elsif notify_method=="proof_unapproved"
        event.roles=["sales_manager"]

      elsif notify_method=="media_assessing_officer_unapproved"
        event.roles=["media_assessing_officer"]


      elsif notify_method=="product_assessing_officer_unapproved"
        event.roles=["product_assessing_officer"]

      elsif notify_method=="legal_officer_unapproved"
        event.roles=["legal_officer"]

      elsif notify_method=="notify_sale"
        event.roles=["sale","team_head"]
      elsif notify_method=="notify_team_header"
        event.roles=["team_head"]
      elsif notify_method=="notify_function_group"
        event.roles=["operaters_manager"]
      elsif notify_method=="notify_operaters_manager"
        event.roles=["operaters_manager","product_assessing_officer"]
      elsif notify_method=="notify_approver"
        event.roles=["sale"]
      elsif notify_method=="notify_operaters_member"
        event.roles=["operater"]
      elsif notify_method=="notify_approver"
        event.roles=["sale"]
      elsif notify_method=="notify_approver"
        event.roles=["sale"]
      end
      event.save

    }
  end
end
