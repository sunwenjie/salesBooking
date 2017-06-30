class GroupsController < ApplicationController
  load_and_authorize_resource
  def index
    @groups = Group.where("status = ?","Active")
  end

  def new
    @group = Group.new
  end
  
  def create
    @group = Group.new(group_params)
     respond_to do |format|
      if @group.save
        @group.childrengroups = params["group"]["childrengroups"] ? (params["group"]["childrengroups"] - [@group.id.to_s] ) : params["group"]["childrengroups"]
        @group.select_users = params["group"]["select_users"]
        group_users = ((Group.round_group_users(params["group"]["childrengroups"])||[]) + (params["group"]["select_users"]||[]) ).uniq
        @group.user_ids = group_users
        flash[:notice] = t('admin.group_update_tip',group_name: "#{@group.name}")
          format.html { redirect_to groups_path }
            #format.html { redirect_to(@client) }
          format.xml  { render :xml => @group, :status => :created, :location => @group }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end
  
  def edit
    @group = Group.find_by_id params[:id]
  end
  
  def update
    @group = Group.find_by_id params[:id]
    @group.childrengroups = params["group"]["childrengroups"] ? (params["group"]["childrengroups"] - [@group.id.to_s] ) : params["group"]["childrengroups"]
    #@group.except_groups = params["group"]["except_groups"]
    @group.select_users = params["group"]["select_users"]
    #@group.except_users = params["group"]["except_users"]
    group_users = ((Group.round_group_users(params["group"]["childrengroups"])||[]) + (params["group"]["select_users"]||[]) ).uniq
    @group.user_ids = group_users
    respond_to do |format|
      if @group.update_attributes(group_params)
        @group.childrengroups = params["group"]["childrengroups"]
        @group.select_users = params["group"]["select_users"]
        group_users = ((Group.round_group_users(params["group"]["childrengroups"])||[]) + (params["group"]["select_users"]||[]) ).uniq
        @group.user_ids = group_users
        @group.save
        roow_group(params[:id])
        flash[:notice] = t('admin.group_update_tip',group_name: "#{@group.name}")
          format.html { redirect_to groups_path }
            #format.html { redirect_to(@client) }
          format.xml  { render :xml => @group, :status => :created, :location => @group }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  #递归处理父组节点
  def roow_group(group_id)
    Group.where("childrengroups is not null").select{|group| group.childrengroups.include? group_id }.each do |group|
      group_users = ( Group.round_group_users(group.childrengroups)||[] + group.select_users||[] ).uniq
      group.user_ids = group_users
      group.save(:validate => false)
      if Group.where("childrengroups is not null").select{|cgroup| cgroup.childrengroups.include? group.id.to_s }.size > 0
        roow_group(group.id.to_s)
      end
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :presentation, :sales_manager_id ,:user_ids => [],:childrengroups => [],:select_users => [])
  end
end
