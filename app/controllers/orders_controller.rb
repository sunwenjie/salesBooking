class OrdersController < ApplicationController

  before_filter :right_tab, :only => [:unapproved, :unproof]
  before_action :api_authenticate, :only => [:create_order_by_business_opportunity]
  before_filter :left_tab, :only => [:index,:unapproved,:approved, :unproof,:proof,:admin_orders,:operater_orders,:undistribute,:distribute]
  skip_before_filter :verify_authenticity_token, :only => ["get_medias","get_sub_interests","interest_preview","export_image", "download_image", "check_type_message", "exchange_rate", "add_ad_form","send_share_emails","bshare_cities","check_download_attr","send_approve","ajax_node_message","ajax_order_state","ajax_order_message","ajax_download_proof","get_locations_info","delete_advertisement","ajax_render_gp_config","order_examine","ajax_get_campaign_code","ajax_get_operate_authority","create_order_by_business_opportunity","change_product_gp"]
  #load_and_authorize_resource :except => ["get_medias","get_sub_interests","interest_preview","export_image", "download_image", "create","update", "check_type_message", "exchange_rate", "add_ad_form","send_share_emails","bshare_cities","check_download_attr","ajax_save_sync_flag","option_for_gp_region","option_for_origin_expand","get_pv_config_data","get_city_max_pv","send_approve","ajax_node_message","ajax_order_state","ajax_order_message","ajax_download_proof","get_locations_info","delete_advertisement","ajax_render_gp_config","order_examine"]
  load_and_authorize_resource :only => ["show","edit","update"]

  include SendDataAxlsx
  include SendMenu 

  sync_attributes_services :order

  def preview
    session[:left_tab] = "orders"
  end
  
  def preview_website
    session[:left_tab] = "orders"
  end
  
  def preview_interest
    session[:left_tab] = "orders"
  end

  def history_list
    examinations = Examination.where(examinable_type: 'Order', examinable_id: params[:id]).where("node_id != 8").where.not("node_id = 3 and status = '1'")
    order = Order.find params[:id]
    if order.schedule_commit_user.present?
      proof_submitter,proof_submit_time = order.schedule_commit_user,order.schedule_commit_time
      examination_proof = Examination.new
      examination_proof.node_id = 8
      examination_proof.status = "1"
      examination_proof.created_user = proof_submitter
      examination_proof.created_at = proof_submit_time
      examinations.push(examination_proof)
    end
    examinations = examinations.to_a.sort_by{|x| x.created_at}
    render partial: "history_list", locals: {items: examinations}
  end
  
  def export_image
    filename = "#{params[:img_name]+Time.now.strftime('%Y%m%d%M%S')}.jpg"
    path = Rails.root.to_s + "/public/quotations_file/" + filename
    Dir.mkdir(Rails.root.to_s + "/public/quotations_file/") if !File.exist?(Rails.root.to_s + "/public/quotations_file/")
    File.open(path, 'wb') do|f|
      f.write(Base64.decode64(params[:img_data]))
    end
    render :json => {:img_url => download_image_orders_path(:filename => filename)}
  end
  
  def download_image
    filename = "#{params[:filename]}"
    path = Rails.root.to_s + "/public/quotations_file/" + filename
    send_file(path, :type => "image/jpg")
  end
  
  def check_download_attr
    order = Order.find(params[:order_id])
    order.check_download_attr[params[:key].to_s] = params[:value]
    order.save
    render :json =>{statu:"success"}
  end

  def get_medias
    industry_id = params[:industry_id] == "ALL" ? ["1","2","3","4","5","6"] : params[:industry_id].split(",")
    ad_format = params[:ad_format] == "ALL" ? [1,2,3] : params[:ad_format].split(",").collect(&:to_i)
    all_sites = MediaList.where("media_category in (?) and ad_format in (?)", industry_id, ad_format)
    render :partial => "media_list", :locals => {:all_sites => all_sites}
  end
  
  def get_sub_interests
    sub_interests = InterestAudience.sub_interests(params[:interest_ids])
    sub_interests_options = sub_interests.collect{|sub| [sub.name, sub.audience_id]}
    render :json => {:sub_interests_options => sub_interests_options}
  end
  
  def interest_preview
    interest_audiences = InterestAudience.interest_detail(params[:interest_ids])
    render :partial => "interest_detail", :locals => {:interest_audience_result => interest_audiences}
  end
  
  def index
    @targ = "订单列表"
  end

  def loading_all
    @orders = Order.with_orders(current_user.id,params[:date_range])
    @options = Operation.all.group_by(&:order_id)
    @pre_check_orders  = Set.new(Order.orders_by_pre_check.map(&:id))
    @gp_submit_orders = Set.new(Examination.find_by_sql("select e.examinable_id from examinations e , (select examinable_id,max(id) as id from examinations
                                                 where examinable_type = 'Order' and node_id = 7 group by examinable_id ) t where e.id = t.id and status = '1' ").map(&:examinable_id))
    unless @orders.present?
      render :js => "window.location.href = '#{welcome_orders_path}';" 
    else
      render :partial => "index", :locals => {:orders => @orders, :options => @options}
    end
  end


  def ajax_node_message
      type = params[:type]
      order = Order.find(params[:order_id])
      position = params[:position] || ""
      status = params[:status]
      node_ids = params[:node_ids]
      if ['pre_check','order_approval','contract_check','order_distribution','gp_control'].include? type

        is_nonstandard = params[:is_nonstandard] == "true" ? true : false
        node_ids = node_ids.split(",").uniq || []
        is_pre_check = params[:is_pre_check] == "true" ? true :false
        locals_params = {:type => type, :order => order, :node_ids => node_ids, :status => status,:is_nonstandard =>is_nonstandard,:position => position,:is_pre_check => is_pre_check}
      elsif type == 'schedul_list'
          locals_params = {:type => type, :order => order,:node_ids => node_ids,:status => status,:position => position}
      end
      render :partial => "last_commit_approval_message", :locals => locals_params
  end

  def ajax_order_state
    order = Order.find (params[:order_id])
    is_statndard_or_unstatnard = params[:is_statndard_or_unstatnard] == "true" ? true : false
    status =  params[:status].join(",")
    gp_submit_orders = params[:gp_submit_orders].map{|x| x.to_i} rescue []
    order_state =  order.map_order_status(status,is_statndard_or_unstatnard,gp_submit_orders)
    render :json=> {order_state:order_state}
  end

  def ajax_order_message
    type = params[:type]
    order = Order.all.where({"id"=>params[:order_id]}).preload(:advertisements).preload(:client).preload(:user)
    locals_params = {:type => type,:order => order[0]}
    render :partial => "ads_and_client_message", :locals => locals_params
  end

  def welcome
    
  end

  def unproof
    @orders = Order.with_unapproved(current_user).with_state("proof_unapproved").descend_by_updated_at;@targ = "待审批排期表"
    render :action=>"index"
  end

  def proof
    @proof_orders = Order.with_approved(current_user).descend_by_updated_at
    @orders=[]
    @proof_orders.each do |order|
      @orders<<order if order.proof_attachment.url && order.state!="proof_unapproved"
    end
    @targ = "已审批排期表"
    render :action=>"index"
  end

  def send_country_citys
    @send_city = ["SPECIAL","OTHER","NATION","SPECIAL_CITY"].include?(@order.regional) ? @order.regional : nil
    @send_country = ["SPECIAL","OTHER","NATION","SPECIAL_CITY"].include?(@order.regional.to_s) ? "CHINA" : @order.regional
  end

  def show
    @order = Order.find(params[:id])
    @order.title = "-" if @order.title.nil?
    @tab = params[:tab].present? ? params[:tab] : "tab-order"
    # @user_for_order_edit = @order.can_edit?(current_user)
    @advertisements = @order.advertisements.order("updated_at desc")
    @order_approval_flow = Order.with_current_order(current_user.id,@order.id).last

    # send_country_citys
    sync_attributes_read_orders
  end

  def new
    @order = Order.new
    @clone_order = Order.find_by_id params[:clone_id]
    clone_order_attributes if @clone_order.present?
  end
  
  def clone_order_attributes
    @order.attributes = @clone_order.dup.attributes
    clone_client =  @clone_order.client
    if clone_client.present?
      client_flag = true
      if (!current_user.manageable_clients.include? clone_client) &&  (clone_client.user_id != current_user.user_id)  && !current_user.administrator?
        client_flag = false
        @order.client = nil
        @order.linkman = nil
        @order.linkman_tel = nil
      end
    else
      client_flag = false
    end
    @order.proof_state = nil
    @order.planner_check = nil
    @order.code = @order.class.create_sn
    @order.title = @clone_order.client.clientname + "_" + (100000..999999).to_a.sample.to_s if client_flag
    @order.state = "order_saved"
    @share_order = @clone_order.share_orders ? @clone_order.share_orders.map(&:share_id) : []
    @share_order_group = @clone_order.share_order_groups ? @clone_order.share_order_groups.map(&:share_id) : []
    send_country_citys
  end

  def edit
    @order = Order.find(params[:id])
    @order.title = "-" if @order.title.nil?
    @tab = params[:tab].present? ? params[:tab] : "tab-order"
    @advertisements = @order.advertisements.order("updated_at desc")
    @order_approval_flow = Order.with_current_order(current_user.id,@order.id).last

    # send_country_citys
    sync_attributes_read_orders
    if params[:submit_to_edit]
      if @order.whether_executive?
        @order.valid_executive
      else
        @order.valid?
      end
    end
  end

  def ajax_render_gp_config
    @order = Order.find params[:id]
    render :partial => "gp_config"
  end

  def ajax_get_campaign_code
    code = params[:code] if params[:code].present?
    have_code = Order.campaign_have_code(code)
    render text: have_code
  end







def create
    params.permit!
    order_hash = params[:order]
    @order = Order.new(params[:order])
    @order.attributes = order_hash
    @order.start_date = params[:date_range].split("~")[0]
    @order.ending_date = params[:date_range].split("~")[1]
    @order.exclude_date = params[:exclude_dates] ? params[:exclude_dates].split(",") : []

    @send_city = params[:send_country]== "CHINA" ? params[:send_country] : nil
    @send_country = params[:send_country]
    @order.user_id = current_user.id
    all_nonuniforms_date_range = params.select{|k,v| k =~ /^nonuniform_date_range(\d+|)$/ }.reject {|key,val| val == "" }
    all_nonuniform_budget = params.select{|k,v| k =~ /^nonuniform_budget(\d+|)$/ }.reject {|key,val| val == "" }

    have_order_code = Order.find_by_code(params[:order][:code])
    respond_to do |format|
      if (params[:commit] == t("order.preview_and_submit") || have_order_code ) ? (@order.save && params[:share_order] && params[:share_order_group]) : @order.save(:validate => false)
          # 拓展属性保存
          params[:id] = @order.id
          if params[:clone_id].present?
            @clone_order = Order.find_by_id params[:clone_id]
            @clone_order.clone_ads.each{|ad|
             ad.order_id = @order.id
              ad.save(:validate=>false)
            }
          end

          rebate = @order.get_channel_rebate
          @order.update_columns({:rebate=>rebate})

          if params[:share_order_group]
            params[:share_order_group].each do |share_order_group_id|
               share_order_group = ShareOrderGroup.new
               share_order_group.order_id = @order.id
               share_order_group.share_id = share_order_group_id
               share_order_group.save
            end
          end
          if params[:order][:whether_business_opportunity] == "1" && params[:order][:business_opportunity_number] !=""
          BusinessOpportunityOrder.create(:business_opportunity_id => params[:order][:business_opportunity_number],:order_id => @order.id)

          #根据商机创建产品
          if  params[:clone_id].blank?
          advertisements_attributes = Order.advertisements_from_business_opportunity(params[:order][:business_opportunity_number])
          @order.advertisements.create(advertisements_attributes)
          end
          @order.set_business_opportunities_process("order_service_create")
          end

          OrderNonuniform.insert_order_nonuniforms(@order.id,all_nonuniforms_date_range,all_nonuniform_budget) if (all_nonuniforms_date_range.present? && all_nonuniform_budget.present? && @order.whether_service == false)


          update_share_orders

          ScheduleWorker.perform_async(@order.id) if  !@order.validate_ability_column?
          flash[:notice] = t("order.form.save_success_tip")
          flash[:notice] = t("order.form.save_success_tip_less") if @order.validate_ability_column?
          format.html { redirect_to ( order_path(:id=> @order.id,:tab=> @order.whether_service? ? "tab-schedule" : "tab-ads" ) ) }
          format.xml  { render :xml => @order, :status => :created, :location => @order }
      else
          instance_variable_set("@share_sales_order_ids",params[:share_order])
          @share_order_group = params[:share_order_group]
          @order.errors.add(:share_order_blank, t("order.form.order_owner_error")) unless params[:share_order]
          @order.errors.add(:share_order_group_blank, t("order.form.order_group_error")) unless params[:share_order_group]
          format.html { render :action => "new" }
          format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
    end
  end


  def translate_admeasure(admeasure_org)
    admeasure = admeasure_org[0..-2]
    admeasure_region = admeasure.map{|x|"'"+x[0].gsub(/\'/,"''") +"'"}.join(",")
    cities = LocationCode.find_by_sql("select * from (select city_name,city_name_cn from xmo.location_codes where country_name = 'China' union all select replace(name,' ','') as city_name,name_cn as city_name_cn from xmo.province_codes) t where t.city_name in ("+admeasure_region+") or t.city_name_cn in ("+admeasure_region+") ")
    cities_en = cities.map{|city| [city["city_name"],city["city_name_cn"]]}.to_h
    cities_cn = cities_en.invert
    admeasure_t = admeasure_org[0..-2].map{|a|
      [I18n.locale.to_s == "en" ? cities_en[a[0]]: cities_cn[a[0]],a[1]]
    }
    admeasure_t << [I18n.locale.to_s == "en" ? "全部" : "All",admeasure_org[-1][1]]
  end

  def update
      #拓展属性保存
      @order = Order.find(params[:id])
      origin_order = Order.new
      origin_order.attributes = @order.attributes
      # unless @order.can_edit?(current_user)
      #   flash[:error] = t("order.form.act_devise_error")
      #   redirect_to :action=>"index"
      # else
      params.permit!
      update_share_orders
      params["order"]["free_tag"] = nil unless params["order"]["free_tag"]
      ShareOrderGroup.connection.delete("delete from share_order_groups where order_id = #{@order.id}")
      
      (params[:share_order_group]||[]).each do |share_order_group_id|
             share_order_group = ShareOrderGroup.new
             share_order_group.order_id = @order.id
             share_order_group.share_id = share_order_group_id
             share_order_group.save
      end
      @order.attributes = params[:order]
      respond_to do |format|
        params[:order][:budget]=nil if params[:order][:budget].empty?
        if params[:order][:city].class == String
          params[:order][:city] = params[:order][:city].split(",")
        end
        @send_city = params[:send_country]== "CHINA" ? params[:send_country] : nil
        @send_country = params[:send_country]
        @order.start_date = params[:date_range].split("~")[0]
        @order.ending_date = params[:date_range].split("~")[1]
        @order.exclude_date = params[:exclude_dates] ? params[:exclude_dates].split(",") : []

        all_nonuniforms_date_range = params.select{|k,v| k =~ /^nonuniform_date_range(\d+|)$/ }.reject {|key,val| val == "" }
        all_nonuniform_budget = params.select{|k,v| k =~ /^nonuniform_budget(\d+|)$/ }.reject {|key,val| val == "" }
        if params[:order][:whether_business_opportunity] == "1" && params[:order][:business_opportunity_number] != ""
          if @order.business_opportunity_orders.present?
            BusinessOpportunityOrder.connection().update "update business_opportunity_orders set business_opportunity_id = #{params[:order][:business_opportunity_number]}  where order_id = #{@order.id}"
          else
            BusinessOpportunityOrder.create(:business_opportunity_id =>params[:order][:business_opportunity_number],:order_id => @order.id)
          end
        else
            BusinessOpportunityOrder.connection().delete "delete from business_opportunity_orders where order_id = #{@order.id}"
        end

        # p "=========update========="
        # p all_nonuniforms_date_range
        # p all_nonuniform_budget
        OrderNonuniform.connection.delete("delete from order_nonuniforms where order_id = #{@order.id}")
        OrderNonuniform.insert_order_nonuniforms(@order.id,all_nonuniforms_date_range,all_nonuniform_budget) if (all_nonuniforms_date_range.present? && all_nonuniform_budget.present? && @order.whether_service == false)

        if @order.save(:validate=>false)
              ScheduleWorker.perform_async(@order.id) #if  !@order.validate_ability_column?
              flash[:notice] = t("order.form.save_success_tip1")
              # flash[:notice] = t("order.form.save_success_tip_less") if @order.validate_ability_column?
              format.html { redirect_to ( order_path(:id=> @order.id,:tab=>"tab-order" ) ) }
              @order.update_order_examinations_status(origin_order,current_user)
              format.xml  { render :xml => @order, :status => :updated, :location => @order }
        else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
        end
      end
    # end
  end

  #新增advertisement
  def new_advertisement
    @order =  Order.find params[:id]
    @advertisement = Advertisement.new
    render :partial => "advertisement_form",:locals => {:flag => "new"}
  end

  #创建新增advertisement
  def create_advertisement
    params.permit!
    advertisement_admeasure(params)
    params[:advertisement][:product_id] =  params[:advertisement][:ad_type] == "OTHERTYPE" ? Product.where("is_delete = false and product_type = 'OTHERTYPE'").last.id : params[:advertisement][:product_id]
    @advertisement = Advertisement.new (params[:advertisement])
    respond_to do |format|
      if   @advertisement.save(:validate => false)
        flash.now[:notice] = t("order.form.save_advertisement_success_tip")
        @order = Order.find (params[:advertisement][:order_id])
        @advertisements = @order.advertisements.order("updated_at desc")
        format.html { render :partial => "order_advertisements",:locals => {:key_word_update => true} }
        format.xml  { render :xml => @advertisement, :status => :created, :location => @advertisement }
      else

        format.html { render :action => "new" }
        format.xml  { render :xml => @advertisement.errors, :status => :unprocessable_entity }
      end
    end

  end

  #编辑advertisement
  def edit_advertisement
    @advertisement = Advertisement.find params[:ad_id]
    @order = @advertisement.order
    flag = params[:flag]
    p 0000000000000
    p flag
    render :partial => "advertisement_form",:locals => {:flag => flag}
  end




  #修改advertisement
  def update_advertisement
    params.permit!
    admeasure_state_param = params[:advertisement][:admeasure_state]
    if admeasure_state_param.present?
    params[:advertisement][:admeasure_state] =  admeasure_state_param
    advertisement_admeasure(params)
    else
      params[:advertisement][:admeasure_state] = nil
      params[:advertisement][:admeasure_en] = nil
      params[:advertisement][:admeasure] = nil
    end
    @advertisement = Advertisement.find params[:ad_id]
    origin_ad = Advertisement.new
    origin_ad.attributes = @advertisement.attributes
    params[:advertisement][:product_id] =  params[:advertisement][:ad_type] == "OTHERTYPE" ? Product.where("is_delete = false and product_type = 'OTHERTYPE'").last.id : params[:advertisement][:product_id]
    respond_to do |format|
      if   @advertisement.update_attributes(params[:advertisement])
        flash.now[:notice] = t("order.form.update_advertisement_success_tip")
        @order = @advertisement.order
        @advertisements = @order.advertisements.order("updated_at desc")
        key_word_update = @advertisement.update_ad_examinations_status(origin_ad,current_user)
        format.html { render :partial => "order_advertisements",:locals => {:key_word_update => key_word_update} }
        format.xml  { render :xml => @advertisement, :status => :created, :location => @advertisement }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @advertisement.errors, :status => :unprocessable_entity }
      end
    end
  end

  def advertisement_admeasure(params)
    if params[:advertisement][:admeasure_state] && params[:ad][:mycity]
      admeasure = []
      params[:ad][:mycity].each_with_index { |city, i|
        admeasure << [city,params[:ad][:myplanner][i].gsub(/,/,'')]
      }
      admeasure <<[params[:ad][:all_mycity],params[:ad][:all_myplanner].gsub(/,/,'')]
      if I18n.locale.to_s == "en"
        params[:advertisement][:admeasure_en] = admeasure
        params[:advertisement][:admeasure] = translate_admeasure(admeasure)
      else
        params[:advertisement][:admeasure] = admeasure
        params[:advertisement][:admeasure_en] = translate_admeasure(admeasure)
      end
    end
    return params
  end


  def order_examine
    @order = Order.find(params[:id])
      need_gp = @order.jast_for_gp_advertisement?
    respond_to do |format|
      if need_gp
          if params["saveflag"] == "save"
            if @order.is_gp_commit
            @order.save_gp_check(current_user,params[:gp_evaluate],params[:agency_rebate],params[:market_cost],params[:net_gp])
            flash.now[:notice] = t('order.form.save_gp_successful')
            else
            flash.now[:error] = t('order.form.save_gp_falt')
            end
          end
      end
          format.html { render :partial => "gp_config"}
          format.xml  { render :xml => @order.errors, :status => :unprocessable_entity }
      end
  end

  #同步SAP请求
  def ajax_save_sync_flag
    if current_user.is?(Role.legal_officer_function_group)
      order_id = params[:order_id]
      @order = Order.find(order_id)
      @order.sync_flag = 0
      if  @order.save!
        render :json => {:suncess => "success"}
      end
    end
  end

  def scheduling
    session[:left_tab] = "orders"
    @order = Order.find(params[:id])
    @user_for_order_edit = @order.can_edit?(current_user)
    send_country_citys
  end

  def download_page
    @order = Order.find(params[:id])
  end

  def download
    @order = Order.find(params[:id])
    @order.generate_schedule
    send_file File.join(Rails.root,"public",@order.schedule_attachment.url)
  end

  def download_proof
    @order = Order.find(params[:id])
    send_file File.join(Rails.root,"public",@order.proof_attachment.url)
  end

  def download_executer
    @order = Order.find(params[:id])
    begin
     #@order.generate_executer
    send_file File.join(Rails.root,"public",@order.executer_attachment.url)
    rescue
    flash[:notice] = t("order.form.execution_plan_not_gen")
    #redirect_to :action=>"scheduling",:id=>@order.id
    redirect_to :action=>"show",:id=>@order.id, :tab => "tab-schedule"
    end
  end


  def download_draft
    @order = Order.find(params[:id])
    send_file File.join(Rails.root,"public",@order.draft_attachment.url)
  end

  def download_orders
    orders = Order.with_orders(current_user.id,params[:date_range])
    @options = Operation.all.group_by(&:order_id)
    gp_submit_orders = Examination.find_by_sql("select e.examinable_id from examinations e , (select examinable_id,max(id) as id from examinations
                                                 where examinable_type = 'Order' and node_id = 7 group by examinable_id ) t where e.id = t.id and status = '1' ").map(&:examinable_id)
    tmp_directory = File.join(Rails.root,"tmp/datas/")
    tmp_filename = "orders"+"_#{DateTime.now.to_i}.xlsx"

    %x(rm -rf #{tmp_directory}/*)

    send_orders_xlsx(orders,tmp_directory,tmp_filename,gp_submit_orders)
    begin
      send_file File.join(tmp_directory,tmp_filename)
    rescue
      flash[:notice] = t("order.form.download_order_error")
    end
  end

  def import_proof
    @order = Order.find(params[:id])
    params.permit!
     @order.update_user = current_user
    if params["commit"] == t("order.form.generate_spot")
      @order.attributes = params[:order]
      @order.save(:validate => false)
      # ExecuterWorker.perform_async(@order.id)
      Order.find(@order.id).generate_executer
      flash[:notice] = t("order.form.execution_plan_gen_success")
    elsif params["commit"] == t("order.form.upload")
        input_executer
    elsif params["commit"] == t("order.form.submit_button")
       if @order.proof_attachment.url
         @order.proof_state = 0
         @order.schedule_commit_user = current_user.name
         @order.schedule_commit_time = Time.now
         @order.save(:validate => false)
         approval_groups = @order.approval_groups(4)
         language = I18n.locale.to_s
         contract_last_status =  @order.precheck_approval_node_state("contract")
         @order.deal_proof_commit_mail(approval_groups,current_user,language)  if contract_last_status == "1"
         flash[:notice] = t("order.form.spot_paln_submit_success")
       elsif @order.draft_attachment.url
         flash[:error] =  t("order.form.spot_paln_error_tips")
       end
    end
    @order.change_examination_some_node_status(4,current_user)   if params[:contract_status].present? &&  params[:contract_status].split(",")[3] == "3"
     redirect_to :action=>"show",:id=>@order.id, :tab => "tab-schedule"
  end

  def input_executer
    if params[:proof_img] || params[:executer_img]
        # if @order.can_edit?(current_user)

          if params[:proof_img]
             orig_name = params[:proof_img].original_filename
             if %w{.PDF .JPG .PNG .JPEG .XLS .XLSX}.include? File.extname(orig_name).upcase
               @order.proof_attachment = params[:proof_img]
               @order.proof_state = 1 if @order.proof_attachment.url
               @order.save(:validate=>false)
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

        # else
        #   flash[:error] = t("order.form.spot_paln_error_tips1")
        # end
    else
        flash[:error] = t("order.form.spot_paln_error_tips2")
    end
  end

  def allocate
    @order = Order.find(params[:id])
    @sale = User.find(@order.user_id)
    @operation = Operation.new
  end

  def allocate_show
    @order = Order.find(params[:id])
    @operation = @order.operations.last ? @order.operations.last : Operation.new
  end

  def allocate_create
    params.permit!
    @operation = Operation.new
    @operation = Operation.create(params[:operation])
    @operation.save
    if params[:username]
      @order = Order.find(params[:operation][:order_id].to_i)
      @order.approver = current_user.id
      @order.operator = params[:username]
      @order.save
      OperaterWorker.perform_async(@order.id,params[:username])
    end
      flash[:notice] = t("order.form.order_be_shared") if params[:username]
      flash[:error] = t("order.form.order_update_not_am") unless params[:username]
      redirect_to "index"
  end

  def check_city
    @send_city = "#{params[:city]}"
    render :partial=>"city_info"
  end

  def check_country
    @send_country = "#{params[:country]}"
    render :partial=>"country_info"
  end

  def check_share_order_group
    @share_sales_order = params[:share_sales_order] || []
    @order = (params[:order_id] && params[:order_id]!="nil"  ? Order.find(params[:order_id].to_i) : Order.new)
    render :partial=>"order_groups"
  end

  def check_license
    other_license = Order.where("user_id != ?", current_user.id).collect(&:license)
    if other_license.include?(params[:license])
      render :text => "<span style='padding-right: 5px;'><img src='/images/icon_cross.png'/></span>您所填入的商业登记号码已经被使用，请检查并重新填写。"
    else
      render :text => "<img src='/images/icon_tick.png'/>"
    end
  end

  def check_ad_platform
    render :partial=>"ad_type_info", :locals => {:index => params[:current_index].to_i , :actionname => params[:actionname] , :ad_type => params[:ad_type] }
  end

  def check_ad_product
     product = Product.find(params["product_id"])
     render :json => {:cost_type => product.sale_model }
  end


  def check_type_message
    params.delete("action")
    params.delete("controller")
    params.delete("locale")
    params.permit!
    @ad = Advertisement.new()
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
                :cost_can => @ad.special_ad? ? true : @ad.cost_can? }
  end


  def exchange_rate
    rate = ExchangeRate.get_rate(params[:currency], params[:base_currency])
    render :json => {:rate => rate}
  end


  def add_ad_form
    @actionname = params[:actionname]
    render :partial => "advertisement_form", :locals => {:index => params[:current_index].to_i}
  end
  

  def bshare_cities
    delivery_type = params[:delivery_type]
    provinces = params[:provinces]
    mainlands = params[:mainlands].to_s.split(" ")
    pro_cities = City.where(["name in (?)", mainlands]).map(&:name_key)
    province_and_cities = Order.bshare_province_and_cities(delivery_type, provinces)
    render :partial => "bshare_city", :locals => {:province_and_cities => province_and_cities, :select_all_flag => true, :mainlands => pro_cities }
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to :action=>"index"
  end
  
  def proceed_deleted_at
    @order = Order.find(params[:id])
    PvDeal.release_pv(@order.id) #释放流量
    @order.delete
    respond_to do |format|
        format.html { 
          flash[:notice] = t("order.form.delete_order_success")
          redirect_to(:action=>"index")
        }
        format.xml { head :ok }
    end
  end

  def delete_advertisement
    begin
      @advertisement = Advertisement.find(params[:ad_id])
      @advertisement.destroy
      @advertisement.delete_advertisement_all_gps
      @order = @advertisement.order
      @order.change_examinations_status(current_user,'Order')
    rescue ActiveRecord::RecordNotFound
    ensure
      @order = Order.find params[:order_id]
      @advertisements = @order.advertisements
      flash[:notice] = t("order.form.delete_advertisement_success")
      render :partial => "order_advertisements",:locals => {:key_word_update => true}
    end

  end



  def clone
    @order = Order.find(params[:id])
    respond_to do |format|
      format.html {
        redirect_to(:action=>"new", :clone_id => @order.id)
      }
      format.xml  { head :ok }
    end
  end

  def send_share_emails
    begin
      FunctionGroupWorker.perform_async(params[:order_id])
      render json:{msg:t("order.form.send_order_sucess")}
    rescue
      render json:{msg:t("order.form.error_send_order")}
    end
  end

#地域组件结果封装
  def get_locations_info
    provices = LocationCode.find_by_sql("select name_cn,city_level,city_name,city_name_cn,criteria_id,province_id,area,area_cn from province_codes,location_codes where location_codes.province_id = province_codes.code_id and country_name='china' and city_name is not null")
    province_codes = ProvinceCode.find_by_sql("select * from province_codes")
    foreigns = LocationRegion.find_by_sql("select continent_name1 ,continent_name1_en,country_id,country_name,continent_name_en from location_regions where continent_name='全球' and continent_name1_en is not null")
    foreign = []
    china = []
    new_regions = []
    new_regions = get_result_regions(provices,foreigns){ Order.find (params[:o_id]) } || [] if params[:o_id].present?
    foreigns.each do |item|
      f = {foreign_name_cn:item.country_name,foreign_name:item.continent_name_en,foreign_id:item.country_id.to_s,continent_name_cn:item.continent_name1,continent_name:item.continent_name1_en}
      foreign << f
    end

    province_codes.each do |item|
      province = {}
      cities = []
      provices.each do |i|
        if i.province_id == item.code_id
          city = {city_name_cn:i.city_name_cn,city_id:i.criteria_id.to_s,city_name:i.city_name,city_level:i.city_level.blank? ? '' : i.city_level.to_s.gsub("0","")}
          cities << city
        end
      end

      if ["20171","20163","20164","20184"].include? item.code_id.to_s
        item.code_id = cities[0][:city_id]
        cities = []
      end
      province = {provice_id:item.code_id,provice_name_cn:item.name_cn,provice_name:item.name,area:item.area,area_cn:item.area_cn,cities:cities}
      china << province
    end
    render :json =>{china:china,foreign:foreign,result:new_regions,total:provices.count+3}
  end

  def get_result_regions(provices,foreigns,&get_val_block)
    obj = get_val_block.call
    if obj.new_regions.present?
      new_regions = obj.get_new_regions
    else
      # new_regions = obj.get_old_regions(provices,foreigns)
    end
  end

  def ajax_get_operate_authority
    order = Order.find params[:id]
    status = params[:status].split(",")
    authority = order.operate_authority(current_user,params[:node_ids],status)
    render :json => {authority:authority}
  end

  def change_product_gp
    advertisement = Advertisement.find params[:ad_id]
    change_gp = params[:change_gp].to_f
    advertisement.update_columns(:change_gp=>change_gp)
    order_est_gp = advertisement.order.est_gp
    render :json => {order_est_gp:order_est_gp}
  end

  #根据商机自动创建订单
  def create_order_by_business_opportunity
    begin
      business_opportunity_id = params[:business_opportunity_id]
      business_opportunity = BusinessOpportunity.find business_opportunity_id
      business_opportunity_orders = business_opportunity.business_opportunity_orders
      if business_opportunity_orders.size > 0
        return render :json=> {success: false,order_id:nil,reason:'此商机已经生成过订单，请勿重复操作',reason_en:'This sales opportunity has been bound with an order before, please do not generate the order again'}
      elsif business_opportunity_id.to_i == 0
        return render :json=> {success: false,order_id:nil,reason:' 商机不存在或商机已删除',reason_en:'The selected sales opportunity does not exist or the advertiser was deleted'}
      else
        order_id,errors_msg = Order.create_from_business_opportunity(business_opportunity_id)
        if order_id.present?
          return render :json=> {success: true,order_id:order_id,reason:'订单创建成功',reason_en:''}
        else
          case errors_msg
            when 'no_client'
              return render :json=> {success: false,order_id:nil,reason:'商机所选广告主不存在或广告主已删除',reason_en:'The selected advertiser does not exist or the advertiser was deleted'}
            when 'no_product'
            return render :json=> {success: false,order_id:nil,reason:'商机所选产品不存在或产品已删除',reason_en:'The selected product does not exist or the product was deleted'}
            else
            return render :json=> {success: false,order_id:nil,reason:nil,reason_en:nil}
          end
        end
      end

    rescue => e
      p "**********create_order_error:#{e.to_s}"
      return render :json=> {success: false,order_id:nil,reason:"程序异常",reason_en:'System error'}
    end
  end

  #重发待审批邮件
  def resend_approval_email
    node_id = params[:node_id].to_i
    order = Order.find params[:id]
    approval_groups = order.submit_node(node_id)
    local_language = I18n.locale.to_s
    examination = order.node_last_commit_examination(node_id)
    nodes = [{1 =>["Pre-sales Approval","预审"]},{2 =>["Order Approval","审批"]},{3 =>["Non-standard Order Approval","特批"]},{4 =>["Contract Confirmation","合同确认"]},{5 =>["Job Assignment","运营分配"]} ]
    node_status = node_id == 7 ?  ["GP Estimation","毛利预估"] : nodes[node_id-1][node_id]
    begin
    OrderWorker.perform_async(order.id,approval_groups,examination.id,node_status,node_id,local_language,'RESEND') if  approval_groups.present? && examination
    render :json => {success: true}
    rescue
    render :json => {success: false}
    end
  end




 #params['nodename'] 为对应的流程命名,params 传过来的订单ID，是否有审批权限（有权限的传过来对应的node_id）
  def send_approve
    deal_order_approve(params[:list])
    render :json=> {msg:@approve_message,status:@status,color_class:@color_class,operate_node:@operate_node,change_unstandard:@change_unstandard,change_standard:@change_standard,local_language: @local_language}
  end


  #订单提交与审批处理

  def deal_order_approve(params)

    #节点标签
    methodname = params['nodename']
      node = Node.find_by_actionname(methodname)
      @approve_message = ""
      @status = ""
      @color_class = ""
      @operate_node = ""
      @change_unstandard = false
      @change_standard = false
      if node
        @operate_node = node.id == 7 ? 6 : node.id
        class_name = node.model.constantize
        #模型
        @cate = class_name.find(params[:id])


        #节点状态
        status = params[:status]
        #是否有当前操作权限? params["node_id"].precent?
        #注意当角色为admin的时候UI上应该全部params["node_id"]都拥有
        if params["node_id"].present? || status == "1"
          p '0000000000000000'
          comment = params[:comment]
          position = params[:position]
          #订单提交做必填验证
          if node.model == "Order" && @cate.validate_ability_column?
            @order = @cate
            if @order.whether_executive?
              @order.valid_executive
            else
              @order.valid?
            end

           if @order.errors.any?
             html = ""
             submit_tip = position == "show_page" ? t("order.form.order_commit_tip2") : t("order.form.order_commit_tip1",:title=>@order.title,:edit_order_url=>edit_order_path(:id=>@order.id,:submit_to_edit=>true))
             html << %Q(<div id="error_explanation" class="error sticker">
                <h2 style="font-size:20px;">#{submit_tip}</h2>
                <ul>)
                @order.errors.full_messages.each do |msg|
                html << %Q(<li>#{msg}</li>)
                end
                html << %Q(</ul>
               </div>)

             @approve_message = html
             return @approve_message
           end
          end

          #审批节点  审批通过时验证GP预估是否提交
          if (["2","3"].include? params["node_id"]) && status != '1'
             if !@cate.is_gp_commit && @cate.is_jast_for_gp
               @approve_message = %Q(<div id="error_explanation" class="error sticker"> #{t("order.form.prechec_approval_tip",:gp_projection_url=> order_path(:id=>@cate.id, :tab=>"tab-gp"))}</div>)
               return @approve_message
             elsif params["node_id"] == "3"
               approval_gp_authority = ApprovalFlow.where({"id"=>(@cate.current_flows(3) & current_user.special_approval_flows)}).order(:min,:max).first rescue []
               gp_range = Range.new(approval_gp_authority.min,approval_gp_authority.max)   if !approval_gp_authority.blank?
               if !current_user.administrator? && (approval_gp_authority.blank? || (gp_range && (!gp_range.include? @cate.net_gp)))
                 @approve_message = %Q(<div id="error_explanation" class="error sticker"> #{t('order.form.have_no_power')}</div>)
                 return @approve_message
               end
             end
          end

          #合同审批 验证排期表是否已经上传
          if params["node_id"] == '4' && status == '2'
            if @cate.proof_state != "0"
              @approve_message = %Q(<div id="error_explanation" class="error sticker"> #{t("order.form.contract_approval_tip")}</div>)
              return @approve_message
            end
          end

          if status == "1"
            @color_class = "status-submit"
          elsif status == "2"
            @color_class = "status-ready"
          elsif status == "3"
            @color_class = "status-error"
          end


          Order.update_user = current_user
          #当前用户ID
          @cate.approver = current_user

          local_language = I18n.locale.to_s
          @local_language = local_language
          # 保存提交审批记录
          examination = Examination.create :node_id => node.id,
                                           :created_user => @cate.approver.nil? ? '' : @cate.approver.name,
                                           :comment => comment,
                                           :status => status,
                                           :approval => '1',
                                           :examinable_id => @cate.id,
                                           :examinable_type => node.model,
                                           :language => local_language
          # 邮件审批申请
          nodes = [{1 =>["Pre-sales Approval","预审"]},{2 =>["Order Approval","审批"]},{3 =>["Non-standard Order Approval","特批"]},{4 =>["Contract Confirmation","合同确认"]},{5 =>["Job Assignment","运营分配"]} ]
          node_status = node.id == 7 ?  ["GP Estimation","毛利预估"] : nodes[node.id-1][node.id]

          # 运营分配 operations表存入记录
          if methodname == "order_distribution"
            @cate.operator_id = params[:operator_id]
            @cate.operator = params[:operator_id].present?? (User.find params[:operator_id]).name : ""
            @cate.save(:validate=>false)
            @operation = Operation.create(:action=>params[:operation],:comment=>comment,:order_id=>@cate.id)
            if params[:operation] == "config_done"
              @color_class = "status-ready"
            else
              @color_class = "status-submit"
            end
             if @operation && params[:operation_share_ams].present?
               user_ids = params[:operation_share_ams].split(",")
               user_ids.each{|u|
                 ShareAm.create(:user_id => u,:operation_id => @operation.id)
               }
               # 加入运营分配成功之后插入xmo.clientgroups表
               if @cate.operation_am_group.present?
                 client_id = @cate.client_id
                 group_ids = @cate.operation_am_group
                 @cate.insert_into_clientgroups(client_id,group_ids)
               end
             end
          end

          #节点提交给审批人发邮件
          if status == "1"
            approval_groups = @cate.submit_node(node.id)

            OrderWorker.perform_async(@cate.id,approval_groups,examination.id,node_status,node.id,local_language) if  approval_groups.present?

            #预审提交时毛利预估未提交，发邮件给毛利预估人
            if node.id == 1 && @cate.is_jast_for_gp
              gp_node_status = @cate.precheck_approval_node_state("gp_control")
              @cate.send_email_to_gp_estimation(current_user,local_language) if gp_node_status.to_i == 0
            end
          end

          #合同审批通过 给运营分配审批者发邮件，更新商机进度为100%
          if node.id == 4 && status == "2"
            approval_groups = @cate.approval_groups(5)
            oprate_node_status = nodes[4][5]
            OrderWorker.perform_async(@cate.id,approval_groups,examination.id,oprate_node_status,5,local_language) if approval_groups.present?
            @cate.set_business_opportunities_process("contract_approval")
          end

          #毛利核算审批通过
          if node.id == 7 && status == "2"
            #更新订单操作人信息
            @cate.update_gp_commit_info(current_user)
            orderApprovalStatus = @cate.precheck_approval_node_state("order_approval")
            if orderApprovalStatus.to_i == 3
              #重置订单审批节点状态
              @cate.reset_order_approval(current_user)
              @change_standard = true
            else
              #发邮件给大区经理
              @cate.deal_gp_commit_mail(local_language)
            end
          end

          #订单审批通过 更新商机进度为50%
          if (node.id== 2 || node.id == 3) && status == "2"
            @cate.set_business_opportunities_process("order_approval")
            if node.id == 2  #大区经理审批
              if !@cate.whether_service?
              if @cate.net_gp.blank?
                @cate.save_gp_check(current_user)
              end
              if @cate.order_standard_or_unstandard?
                status,color_class,change_unstandard = @cate.deal_region_manager_approval(local_language)
                @color_class = color_class
                @change_unstandard = change_unstandard
              end
              end
            end
          end

          #订单审批不通过 重置GP状态

          if (node.id == 2 || node.id == 3) && status == "3"
            @cate.deal_reset_gp(current_user,local_language)
          end


          # 审批回复邮件
          other_useremail = User.where({"id"=>@cate.operator_and_share_opertor}).map(&:useremail) if node.id == 5

          SaleWorker.perform_async(@cate.id,node_status,status,local_language,other_useremail,current_user.id) if (status != "0" && status != "1")
          @status = status
          # @approve_message = methodname+status #I18n.t(methodname+status)

        elsif  (@cate.operator_and_share_opertor.include? current_user.id)  &&  node.id == 5
          @cate.operator_id = params[:operator_id]
          @cate.operator = (User.find params[:operator_id]).name
          @cate.save(:validate=>false)
          comment = params[:comment]
          @operation = Operation.create(:action=>params[:operation],:comment=>comment,:order_id=>@cate.id)
          if params[:operation] == "config_done"
            @color_class = "status-ready"
          else
            @color_class = "status-submit"
          end
          if @operation && params[:operation_share_ams].present?
            user_ids = params[:operation_share_ams].split(",")
            user_ids.each{|u|
              ShareAm.create(:user_id => u,:operation_id => @operation.id)
            }
          end
        else
          #可以审批该订单的群组
          # groups = Group.where({"id" => approval_flows.map(&:approval_group)}).map(&:group_name).join(",")

          @approve_message =%Q(<div id="error_explanation" class="error sticker">
                             #{t('order.form.have_no_power')}
                               </div>
                              )
        end

        p 999999999999
        p @approve_message

      else
        super
      end
  end

end
