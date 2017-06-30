class ApprovalFlowsController < ApplicationController

  include SendAxlsx

  skip_before_filter :verify_authenticity_token, :only => [:get_bu_products]
  before_filter :left_tab, :only => [:index, :new_sales_group_type]

  def index
    @list = ApprovalFlow.all.order(updated_at: :desc).includes(:node, :group)
  end

  def new
    @approval_flow = ApprovalFlow.new
    @nodes = []
  end

  def edit
    @approval_flow = ApprovalFlow.find(params[:id])
  end

  def create
    params.permit!
    @approval_flow = ApprovalFlow.new(approval_flows_attributes(params))
    respond_to do |format|
      if @approval_flow.save
        flash[:notice] = t('approval_flows.form.approval_flows_created')
        format.html { redirect_to(action: :index) }
        format.xml { render :xml => @approval_flow, :status => :created, :location => @approval_flow }
      else
        format.html { render :new }
        @approval_flow.min = nil if @approval_flow.min = -10000.00
        format.xml { render :xml => @approval_flow.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update
    params.permit!
    @approval_flow = ApprovalFlow.find(params[:id])
    respond_to do |format|
      if @approval_flow.update(approval_flows_attributes(params))
        flash[:notice] = t('approval_flows.form.approval_flows_edit')
        format.html { redirect_to(action: :index) }
        format.xml { render :xml => @approval_flow, :status => :created, :location => @approval_flow }
      else
        format.html { render :edit }
        @approval_flow.min = nil if @approval_flow.min = -10000.00
        format.xml { render :xml => @approval_flow.errors, :status => :unprocessable_entity }
      end
    end

  end

  def get_bu_products
    language = I18n.locale.to_s
    @products = [[language == 'en' ? 'All' : '全部', 'ALL']]
    list = Product.bu_product(params[:bu])
    @products += list.collect { |product| [product.product_type, product.product_type] }.uniq << [language == 'en' ? 'OTHER' : '其他', 'OTHERTYPE']
    render partial: 'bu_products', locals: {products: @products}
  end


  def new_sales_group_type
    params[:direct_sales_group] = Group.with_groups_by_type('direct_sales')
    params[:channel_sales_group] = Group.with_groups_by_type('channel_sales')
  end

  def set_sales_group_type
    direct_sales_group = params[:direct_sales_group] || []
    channel_sales_group = params[:channel_sales_group] || []
    respond_to do |format|
      if (direct_sales_group & channel_sales_group).size > 0
        notice = t('approval_flows.form.sales_group_type_notice')
      else
        notice = t('approval_flows.form.sales_group_type')
        Group.update_sales_group_type(direct_sales_group, channel_sales_group)
      end
      flash[:notice] = notice
      format.html { redirect_to(:action => 'new_sales_group_type', :direct_sales_group => direct_sales_group, :channel_sales_group => channel_sales_group) }
    end

  end

  def delete_approval_flow
    approval_flow = ApprovalFlow.find params[:id]
    respond_to do |format|
      if approval_flow.destroy
        flash[:notice] = t('approval_flows.index.notice_delete_success')
      else
        flash[:error] = t('approval_flows.index.notice_delete_error')
      end
      format.html { redirect_to action: :index }
    end

  end

  def download
    approvalflows = ApprovalFlow.all.order(updated_at: :desc).preload(:node).preload(:group)
    tmp_directory = File.join(Rails.root, "tmp/datas/")
    tmp_filename = "user_permissions_#{DateTime.now.to_i}.xlsx"
    %x(rm -rf #{tmp_directory}/*)
    send_flows_xlsx(approvalflows, tmp_directory, tmp_filename)
    begin
      send_file File.join(tmp_directory, tmp_filename)
    rescue
      flash[:notice]= t('approval_flows.index.download_approval_flows_error')
    end
  end

  private

  def approval_flows_attributes(params)
    params[:approval_flow][:coordinate_groups] = params[:approval_flow][:coordinate_groups].reject! { |m| m == '' }
    params[:approval_flow][:p_coordinate_groups] = params[:approval_flow][:p_coordinate_groups].blank? ? nil : params[:approval_flow][:p_coordinate_groups]
    node_id =  params[:approval_flow][:node_id].to_i
    if node_id == 3
      params[:approval_flow].merge!({min: -10000.00}) if params[:approval_flow][:range_type] == '<=' && params[:approval_flow][:min] == ''
    else
      params[:approval_flow][:range_type] = nil
    end
    model = Node.find(node_id).model if node_id.present?
    params[:approval_flow].merge!({model: model})
  end

end
