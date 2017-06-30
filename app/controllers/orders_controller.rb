class OrdersController < ApplicationController

  include SendAxlsx

  before_action :api_authenticate, :only => [:create_order_by_business_opportunity]

  skip_before_filter :verify_authenticity_token, :only => [:check_type_message, :exchange_rate, :send_share_emails, :check_download_attr,
                                                           :send_approve, :ajax_node_message, :ajax_order_state, :ajax_order_message, :get_locations_info,
                                                           :delete_advertisement, :ajax_render_gp_config, :order_examine, :ajax_get_campaign_code, :ajax_get_operate_authority,
                                                           :create_order_by_business_opportunity, :change_product_gp]

  load_and_authorize_resource :only => [:show, :edit, :update]

  share_sales_services :order

  before_filter :left_tab, :only => [:index]

  def history_list
    order = Order.find params[:id]
    examinations = order.history_list_data
    render :partial => 'history_list', locals: {items: examinations}
  end

  def check_download_attr
    order = Order.find(params[:order_id])
    order.check_download_attr[params[:key].to_s] = params[:value]
    order.save
    render json: {statu: 'success'}
  end


  def index
  end

  def loading_all
    @orders = Order.with_orders(current_user.id, params[:date_range])
    unless @orders.present?
      render :js => "window.location.href = '#{welcome_orders_path}';"
    else
      render :partial => 'index', locals: {orders: @orders}
    end
  end

  def ajax_node_message
    type = params[:type]
    order = Order.find(params[:order_id])
    node_ids = params[:node_ids]
    if type.in? %w{pre_check order_approval contract_check contract_check order_distribution gp_control}
      is_nonstandard = params[:is_nonstandard] == 'true' ? true : false
      node_ids = node_ids.split(',').uniq || []
      is_pre_check = params[:is_pre_check] == 'true' ? true : false
      locals_params = {type: type, order: order, node_ids: node_ids, status: params[:status], is_nonstandard: is_nonstandard, position: params[:position] || '', is_pre_check: is_pre_check}
    elsif type == 'schedul_list'
      locals_params = {type: type, order: order, node_ids: node_ids, status: params[:status], position: params[:position] || ''}
    end
    render :partial => 'last_commit_approval_message', :locals => locals_params
  end

  def ajax_order_state
    order = Order.find (params[:order_id])
    is_statndard_or_unstatnard = params[:is_statndard_or_unstatnard] == 'true' ? true : false
    status = params[:status].join(',')
    gp_submit_orders = params[:gp_submit_orders].map { |order_id| order_id.to_i } rescue []
    order_state = order.map_order_status(status, is_statndard_or_unstatnard, gp_submit_orders)
    render :json => {order_state: order_state}
  end

  def ajax_order_message
    order = Order.find_by(:id => params[:order_id])
    locals_params = {:type => params[:type], :order => order}
    render :partial => 'ads_and_client_message', :locals => locals_params
  end

  def welcome
  end


  def show
    @order = Order.find(params[:id])
    @order.title = '-' if !@order.title?
    #设置销售人员给@share_sales_order_ids
    share_sales_read_orders(@order.id)
  end

  def new
    @clone_order = Order.find_by_id params[:clone_id]
    @order = @clone_order ? Order.clone_order(@clone_order, current_user) : Order.new
  end

  def edit
    @order = Order.find(params[:id])
    @order.title = '-' if !@order.title?
    #设置销售人员给@share_sales_order_ids
    share_sales_read_orders(@order.id)
    @order.valid_edit(params[:submit_to_edit])
  end

  def ajax_render_gp_config
    @order = Order.find params[:id]
    render partial: 'gp_config'
  end

  def ajax_get_campaign_code
    code = params[:code]
    have_code = Order.campaign_have_code(code) if code
    render text: have_code
  end

  def create
    params.permit!
    @order = Order.new_order_by_user(params, current_user)
    respond_to do |format|
      if @order.save(:validate => false)
        @order.set_business_opportunities_process('order_service_create') if params[:order][:whether_business_opportunity] == '1' && params[:order][:business_opportunity_number] != ''
        ScheduleWorker.perform_async(@order.id)
        flash[:notice] = t('order.form.save_success_tip')
        format.html { redirect_to (order_path(:id => @order.id, :tab => @order.whether_service? ? 'tab-schedule' : 'tab-ads')) }
        format.xml { render :xml => @order, :status => :created, :location => @order }
      else
        format.html { render :new }
        format.xml { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params.permit!
    origin_order, @order = Order.update_order(params)
    respond_to do |format|
      if @order.save(validate: false)
        ScheduleWorker.perform_async(@order.id)
        flash[:notice] = t('order.form.save_success_tip1')
        format.html { redirect_to (order_path(:id => @order.id, :tab => 'tab-order')) }
        @order.update_order_examinations_status(origin_order, current_user)
        format.xml { render :xml => @order, :status => :updated, :location => @order }
      else
        format.html { render :edit }
        format.xml { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end

  def order_examine
    @order = Order.find(params[:id])
    need_gp = @order.jast_for_gp_advertisement?
    respond_to do |format|
      if need_gp && params[:saveflag] == 'save'
        if @order.is_gp_commit
          @order.save_gp_check(current_user, params[:gp_evaluate], params[:agency_rebate], params[:market_cost], params[:net_gp])
          flash.now[:notice] = t('order.form.save_gp_successful')
        else
          flash.now[:error] = t('order.form.save_gp_falt')
        end
      end
      format.html { render :partial => 'gp_config' }
      format.xml { render :xml => @order.errors, :status => :unprocessable_entity }
    end
  end

  def download
    @order = Order.find(params[:id])
    @order.generate_schedule
    send_file File.join(Rails.root, 'public', @order.schedule_attachment.url)
  end

  def download_proof
    @order = Order.find(params[:id])
    send_file File.join(Rails.root, 'public', @order.proof_attachment.url)
  end

  def download_executer
    @order = Order.find(params[:id])
    begin
      send_file File.join(Rails.root, 'public', @order.executer_attachment.url)
    rescue
      flash[:notice] = t('order.form.execution_plan_not_gen')
      redirect_to :action => 'show', :id => @order.id, :tab => 'tab-schedule'
    end
  end

  def download_draft
    @order = Order.find(params[:id])
    send_file File.join(Rails.root, 'public', @order.draft_attachment.url)
  end

  def download_orders
    orders = Order.with_orders(current_user.id, params[:date_range])
    @options = Operation.all.group_by(&:order_id)
    gp_submit_orders = Examination.all_gp_submit
    tmp_directory = File.join(Rails.root, 'tmp/datas/')
    tmp_filename = "orders_#{DateTime.now.to_i}.xlsx"
    %x(rm -rf #{tmp_directory}/*)
    send_orders_xlsx(orders, tmp_directory, tmp_filename, gp_submit_orders)
    begin
      send_file File.join(tmp_directory, tmp_filename)
    rescue
      flash[:notice] = t('order.form.download_order_error')
    end
  end

  def import_proof
    @order = Order.find(params[:id])
    params.permit!
    @order.update_user = current_user
    if params['commit'] == t('order.form.generate_spot')
      @order.save(:validate => false)
      @order.generate_executer
      flash[:notice] = t('order.form.execution_plan_gen_success')
    elsif params['commit'] == t('order.form.upload')
      input_executer
    elsif params['commit'] == t('order.form.submit_button')
      if @order.proof_attachment.url
        @order.proof_submit(current_user)
        flash[:notice] = t('order.form.spot_paln_submit_success')
      elsif @order.draft_attachment.url
        flash[:error] = t('order.form.spot_paln_error_tips')
      end
    end
    @order.change_examination_some_node_status(4, current_user) if params[:contract_status].present? && params[:contract_status].split(',')[3] == '3'
    redirect_to :action => 'show', :id => @order.id, :tab => 'tab-schedule'
  end

  def input_executer
    if params[:proof_img] || params[:executer_img]
      if params[:proof_img]
        orig_name = params[:proof_img].original_filename
        if %w{.PDF .JPG .PNG .JPEG .XLS .XLSX}.include? File.extname(orig_name).upcase
          @order.proof_attachment = params[:proof_img]
          @order.proof_state = 1 if @order.proof_attachment.url
          @order.save(:validate => false)
          flash[:notice] = t("order.form.spot_list_sucess_upload")
        else
          flash[:error] = t("order.form.spot_list_type_tip")
        end
      end
      if params[:executer_img]
        orig_name = params[:executer_img].original_filename
        if %w{.PDF .JPG .PNG .JPEG}.include? File.extname(orig_name).upcase
          @order.draft_attachment = params[:executer_img]
          @order.save(:validate => false)
          flash[:notice] = flash[:notice].to_s+ " " + t("order.form.client_confirm_upload_success")
        else
          flash[:error] = flash[:error].to_s+ " " + t("order.form.client_confirm_type_tip")
        end
      end
    else
      flash[:error] = t("order.form.spot_paln_error_tips2")
    end
  end

  def check_share_order_group
    share_user_ids = params[:share_sales_order] || []
    share_group_ids = params[:share_order_group] || []
    render :partial => 'order_groups', locals: {share_user_ids: share_user_ids, share_group_ids: share_group_ids}
  end

  def check_ad_product
    product = Product.find(params['product_id'])
    render :json => {:cost_type => product.sale_model}
  end

  def check_type_message
    params.delete('action')
    params.delete('controller')
    params.delete('locale')
    @ad = Advertisement.new
    @ad.attributes = params.permit!

    impressions_prediction = @ad.impressions_prediction
    clicks_prediction = @ad.clicks_prediction
    ctr_prediction = @ad.forecast_ctr
    general_price = @ad.general_price
    cpm_prediction = @ad.cpm_prediction
    cpc_prediction = @ad.cpc_prediction
    public_price = @ad.public_price
    cpe_times = @ad.cpe_times

    render :json => {
               :ctr_prediction => ctr_prediction,
               :clicks_prediction => clicks_prediction,
               :impressions_prediction => impressions_prediction,
               :cpm_prediction => cpm_prediction,
               :cpc_prediction => cpc_prediction,
               :general_price => general_price,
               :public_price => public_price,
               :cpe_times => cpe_times,
               :cost_can => @ad.special_ad? ? true : @ad.cost_can?}
  end


  def exchange_rate
    rate = ExchangeRate.get_rate(params[:currency], params[:base_currency])
    render :json => {:rate => rate}
  end


  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to action: :index
  end

  def proceed_deleted_at
    @order = Order.find(params[:id])
    @order.delete
    respond_to do |format|
      format.html {
        flash[:notice] = t('order.form.delete_order_success')
        redirect_to(action: :index)
      }
      format.xml { head :ok }
    end
  end

  def delete_advertisement
    begin
      @advertisement = Advertisement.find(params[:ad_id])
      @advertisement.destroy
      @order = @advertisement.order
      @order.change_examinations_status(current_user)
    rescue ActiveRecord::RecordNotFound
    ensure
      flash[:notice] = t('order.form.delete_advertisement_success')
      render :partial => 'order_advertisements', :locals => {:key_word_update => true}
    end
  end


  def clone
    @order = Order.find(params[:id])
    respond_to do |format|
      format.html {
        redirect_to(action: :new, clone_id: @order.id)
      }
      format.xml { head :ok }
    end
  end

  #地域组件结果封装
  def get_locations_info
    order = (Order.find params[:o_id]) rescue Order.new
    china, foreign, new_regions, total = order.locations_info
    render :json => {china: china, foreign: foreign, result: new_regions, total: total}
  end


  def ajax_get_operate_authority
    order = Order.find params[:id]
    status = params[:status].split(',')
    authority = order.operate_authority(current_user, params[:node_ids], status)
    render :json => {authority: authority}
  end

  def change_product_gp
    advertisement = Advertisement.find params[:ad_id]
    change_gp = params[:change_gp].to_f
    if advertisement.update_change_gp(change_gp)
      order_est_gp = advertisement.order.est_gp
    else
      order_est_gp = 0
    end
    render :json => {order_est_gp: order_est_gp}
  end

  #根据商机自动创建订单
  def create_order_by_business_opportunity
    begin
      business_opportunity_id = params[:business_opportunity_id]
      business_opportunity = BusinessOpportunity.find business_opportunity_id
      business_opportunity_orders = business_opportunity.business_opportunity_orders
      if business_opportunity_orders.size > 0
        return render :json => {success: false, order_id: nil, reason: '此商机已经生成过订单，请勿重复操作', reason_en: 'This sales opportunity has been bound with an order before, please do not generate the order again'}
      elsif business_opportunity_id.to_i == 0
        return render :json => {success: false, order_id: nil, reason: ' 商机不存在或商机已删除', reason_en: 'The selected sales opportunity does not exist or the advertiser was deleted'}
      else
        order_id, errors_msg = Order.create_from_business_opportunity(business_opportunity_id)
        if order_id.present?
          return render :json => {success: true, order_id: order_id, reason: '订单创建成功', reason_en: ''}
        else
          case errors_msg
            when 'no_client'
              return render :json => {success: false, order_id: nil, reason: '商机所选广告主不存在或广告主已删除', reason_en: 'The selected advertiser does not exist or the advertiser was deleted'}
            when 'no_product'
              return render :json => {success: false, order_id: nil, reason: '商机所选产品不存在或产品已删除', reason_en: 'The selected product does not exist or the product was deleted'}
            else
              return render :json => {success: false, order_id: nil, reason: nil, reason_en: nil}
          end
        end
      end

    rescue => e
      p "**********create_order_error:#{e.to_s}"
      return render :json => {success: false, order_id: nil, reason: '程序异常', reason_en: 'System error'}
    end
  end

  #重发待审批邮件
  def resend_approval_email
    node_id = params[:node_id].to_i
    order = Order.find params[:id]
    local_language = I18n.locale.to_s
    examination = order.last_examination_commit(node_id)
    nodes = Order::NODES
    node_status = node_id == 7 ? ['"GP Estimation","毛利预估"'] : nodes[node_id-1][node_id]
    begin
      if order.assign_planner.present? && node_id == 1
        PlannerWorker.perform(order.id, order.assign_planner, examination.id, node_status, local_language, 'RESEND') if examination
      else
        approval_groups = order.submit_node(node_id)
        OrderWorker.perform_async(order.id, approval_groups, examination.id, node_status, node_id, local_language, 'RESEND') if approval_groups.present? && examination
      end
      render :json => {success: true}
    rescue => e
      render :json => {success: false}
    end
  end

  #params['nodename'] 为对应的流程命名,params 传过来的订单ID，是否有审批权限（有权限的传过来对应的node_id）
  def send_approve
    @order = Order.find(params[:list][:id])
    approve_message, status, color_class, operate_node, change_unstandard, change_standard, local_language = @order.deal_order_submit_approver(params[:list], current_user)
    render :json => {msg: approve_message.to_s,
                     status: status.to_s,
                     color_class: color_class.to_s,
                     operate_node: operate_node,
                     change_unstandard: change_unstandard,
                     change_standard: change_standard,
                     local_language: local_language
           }
  end

end
