class ApprovalFlowsController < ApplicationController

  include SendDataAxlsx

  skip_before_filter :verify_authenticity_token, :only => [:get_bu_products]
  before_filter :left_tab, :only => [:index,:new_sales_group_type]

  def index
    @list = ApprovalFlow.all.order(updated_at: :desc).preload(:node).preload(:group)
  end

  def new
    @approval_flow = ApprovalFlow.new
    @nodes = []
    @tag = "新增审批环节"
  end

  def edit
    @approval_flow = ApprovalFlow.find(params[:id])
    @tag = "编辑审批环节"
  end

  def create
    params.permit!
    params[:approval_flow][:operation_am_group] = params[:approval_flow][:operation_am_group].reject!{|m| m == ""}
    model = Node.find(params[:approval_flow][:node_id].to_i).model if params[:approval_flow][:node_id].present?
    @approval_flow = ApprovalFlow.new(params[:approval_flow].merge!({model:model}))
     if @approval_flow.node_id == 3
       @approval_flow.min = -10000.00 if @approval_flow.range_type == '<=' &&  @approval_flow.min.blank?
     else
       @approval_flow.range_type = nil
     end
    respond_to do |format|
      if @approval_flow.save
        flash[:notice] = t("approval_flows.form.approval_flows_created")
        format.html { redirect_to(:action=>"index") }
        format.xml  { render :xml => @approval_flow, :status => :created, :location => @approval_flow }
      else
        format.html { render :action => "new" }
        @approval_flow.min = nil if @approval_flow.min = -10000.00
        format.xml  { render :xml => @approval_flow.errors, :status => :unprocessable_entity }
      end
    end
    
  end



  def update
    params.permit!
    params[:approval_flow][:operation_am_group] = params[:approval_flow][:operation_am_group].reject!{|m| m == ""}
    @approval_flow = ApprovalFlow.find(params[:id])
    model = Node.find(params[:approval_flow][:node_id].to_i).model if params[:approval_flow][:node_id].present?
    if params[:approval_flow][:node_id] == '3'
      params[:approval_flow].merge!({min:-10000.00}) if params[:approval_flow][:range_type] == '<=' &&  params[:approval_flow][:min] == ''
    else
      params[:approval_flow][:range_type] = nil
    end

    respond_to do |format|
      if @approval_flow.update(params[:approval_flow].merge!({model:model}))
        flash[:notice] = t("approval_flows.form.approval_flows_edit")
        format.html { redirect_to(:action=>"index") }
        format.xml  { render :xml => @approval_flow, :status => :created, :location => @approval_flow }
      else
        format.html { render :action => "edit" }
        @approval_flow.min = nil if @approval_flow.min = -10000.00
        format.xml  { render :xml => @approval_flow.errors, :status => :unprocessable_entity }
      end
    end

  end

  def get_bu_products
    @products = [[I18n.locale.to_s == "en" ? "All" : "全部","ALL"]]
    list = Product.where("is_delete = ?",false).order("ad_platform","product_type").select{|m|m.bu.to_a.include? params[:bu] }
    @products += list.collect{|product| [product.product_type,product.product_type] }.uniq << [I18n.locale.to_s == "en" ? "OTHER" : "其他","OTHERTYPE"]
    render :partial => "bu_products", :locals => {:products => @products}
  end


  def new_sales_group_type
    params[:direct_sales_group] = Group.where({"sales_group_type"=> "direct_sales"}).map(&:id)
    params[:channel_sales_group] = Group.where({"sales_group_type"=> "channel_sales"}).map(&:id)

  end

  def set_sales_group_type
    direct_sales_group = params[:direct_sales_group] || []
    channel_sales_group = params[:channel_sales_group] || []
    respond_to do |format|
      if (direct_sales_group & channel_sales_group).size > 0
        flash[:notice] = t("approval_flows.form.sales_group_type_notice")
        format.html { redirect_to(:action=>"new_sales_group_type",:direct_sales_group=>direct_sales_group,:channel_sales_group=>channel_sales_group) }
      else
        flash[:notice] = t("approval_flows.form.sales_group_type")
        Group.update_sales_group_type(direct_sales_group,channel_sales_group)
        format.html { redirect_to(:action=>"new_sales_group_type",:direct_sales_group=>direct_sales_group,:channel_sales_group=>channel_sales_group) }
      end
    end

  end

  def delete_approval_flow
    approval_flow = ApprovalFlow.find params[:id]

    respond_to do |format|
      if approval_flow.destroy
        flash[:notice] = t("approval_flows.index.notice_delete_success")
        format.html {redirect_to :action=>"index"}
      else
        flash[:error] = t("approval_flows.index.notice_delete_error")
        format.html {redirect_to :action=>"index"}
      end
    end

  end

  def download
    approvalflows = ApprovalFlow.all.order(updated_at: :desc).preload(:node).preload(:group)
    tmp_directory = File.join(Rails.root,"tmp/datas/")
    tmp_filename = "user_permissions"+"_#{DateTime.now.to_i}.xlsx"
    %x(rm -rf #{tmp_directory}/*)
    send_flows_xlsx(approvalflows,tmp_directory,tmp_filename)
    begin
      send_file File.join(tmp_directory,tmp_filename)
    rescue
      flash[:notice]= t("approval_flows.index.download_approval_flows_error")
    end
  end

  private
    def flow_params
      #params.require(:approval_flow).permit(:name, :node_id,:model,:user_group,:bu,:product_type => [],:approval_group)
    end


  
end
