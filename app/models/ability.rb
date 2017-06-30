class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    if @user.present? && @user.administrator?
     setup_admin_access
    elsif @user.present?
     setup_user_access
    end
  end

  def setup_admin_access
    can :manage, User
    can :manage, Group
    # #can :manage, Order
    # can [:edit,:update], Order do |order|
    #   #can_edit_order = Order.with_orders(@user.id).select{|o| o.status.split(",").include?("3") || o.status.split(",").uniq.join(',') == "0" || o.state == "examine_completed" }.map(&:id)
    #   can_edit_order = Order.with_orders(@user.id).select{|o| (o.status.split(",").include?("3") || (o.status.split(",")[0..3].uniq.join(',') == "0" && o.is_gp_commit.to_s != "1" && o.proof_state != "0" ) || o.state == "examine_completed") }.map(&:id)
    #   can_edit_order.include?(order.id)
    # end
    # #can :manage, Client
    # can [:edit,:update], Client do |client|
    #   can_edit_client = Client.with_sale_clients(@user).select{|c| c.state != "unapproved"}.map(&:id)
    #   can_edit_client.include?(client.id)
    # end
    # can [:show], Order
    # can [:show], Client
    can :manage, Order
    can :manage, Client
    can :manage, Product
    can :manage, ApprovalFlow
    can :manage, Channel
  end

  def setup_user_access
    #can :manage, Order
    #can :manage, Client
    can [:show], Order do |order|
      Order.with_orders(@user.id,'all').map(&:id).include?(order.id)
    end

    can [:edit,:update], Order do |order|
      can_edit_order = Order.with_orders(@user.id,'all').select{|o| ((o.status.split(",").include? "3") || (o.status.split(",").pop(4).uniq.join(',') == "0"  ) || o.state == "examine_completed")  && ((o.operate_authority(@user,o["node_ids"],o["status"]).include? "order_edit") || (o.operate_authority(@user,o["node_ids"],o["status"]).include? "ad_edit")) || ((o["node_ids"].split(",").include? "1") && o["status"].split(",")[0] !="2") || ( (o["node_ids"].split(",").include? "4") && o["status"].split(",")[3] !="2" )}.map(&:id)
      can_edit_order.include?(order.id)
    end

    can [:show], Client do |client|
      Client.with_sale_clients(@user,nil,'all').collect(&:id).include?(client.id)
    end

    can [:edit, :update], Client do |client|
      can_edit_client = Client.with_sale_clients(@user,nil,'all').select{|c| c.state != "unapproved" || c.state != "cross_unapproved"}.map(&:id)
      can_edit_client.include?(client.id)
    end

    cannot :manage, User
    cannot :manage, Group
    cannot :manage, ApprovalFlow

    can :manage, Product if  @user.can_manage_product?

    can :manage, Channel if @user.can_manage_channel?

  end
  
end
