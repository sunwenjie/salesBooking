class ClientsController < ApplicationController
  include SendDataAxlsx
  include SendMenu
  include SendOrderAdvertisementClient
  before_filter :right_tab, :only => [:unapproved]
  before_filter :left_tab, :only => [:index,:unapproved,:approved]
   before_action :api_authenticate, :only => [:client_approval_from_pms]
  skip_before_filter :verify_authenticity_token, :only => [:auto_complete_for_client_name,:send_client_approval,:ajax_client_node_message]
  load_and_authorize_resource :only => ["edit","update"]
  sync_attributes_services :client
  
  def index
  @targ = t("clients.index.client_list")
  end

  def loading_all
    @clients = Client.with_sale_clients(current_user.id,nil,params[:date_range])
    @all_share_clients = ShareClient.find_by_sql("select share_clients.client_id,xmo.users.name,xmo.agencies.name as agency_name from share_clients left join xmo.users on share_clients.share_id = xmo.users.id left join xmo.agencies on xmo.users.agency_id = xmo.agencies.id").group_by(&:client_id)
    render :partial => "index", :locals => {:clients => @clients, :all_share_clients => @all_share_clients}
  end

  def show
    @client = Client.find(params[:id])
    @node_id = params[:node_id]
    @name = Client.all.collect{|c|c.clientname}.uniq
    sync_attributes_read_clients
  end

  def new
    @name = Client.all.collect{|c|c.clientname}.uniq
    @client = Client.new(code: Client.create_sn)
    @tag = t("clients.form.new_client")
  end

  def edit
    @name = Client.all.collect{|c|c.clientname}.uniq
    @client = Client.find(params[:id])
    @node_id = params[:node_id]
    sync_attributes_read_clients
    if params[:submit_to_edit]
      @client.valid?
    end
    @tag = t("clients.form.edit_client")
  end

  def create
    params.permit!
    @client = Client.new(params[:client])

    @client.created_user = current_user.name
    @client.user_id = current_user.id
    @client.state = "cli_saved"
    #xmo group_id 和 manage_option 字段不能为空
    @client.group_id = 0
    @client.manage_option = 'Share'
    @client.agency_id = current_user.agency_id
    business_unit_id = BusinessUnit.where({"agency_id" => current_user.agency_id}).map(&:id).first
    @client.business_unit_id = business_unit_id.nil? ? 1 : business_unit_id
    respond_to do |format|
      if  params[:share_client] && @client.save
         params[:id] = @client.id
         update_share_clients
        flash[:notice] = t("clients.form.client_created")
          format.html { redirect_to(client_path(:id => @client.id)) }
          format.xml  { render :xml => @client, :status => :created, :location => @client }
      else
          instance_variable_set("@share_sales_client_ids",params[:share_client])
          @name = Client.all.collect{|c|c.clientname}.uniq
          @client.errors.add(:share_client_blank, t("clients.form.client_blank")) unless params[:share_client]
          format.html { render :action => "new" }
          format.xml  { render :xml => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params.permit!
    @client = Client.find(params[:id])
    @client.attributes = params[:client]

    respond_to do |format|
    #  if @client.save(:validate=>false) && params[:share_client]
      if  params[:share_client] && @client.save
        update_share_clients
         if @client.state == "cli_rejected"
           change_success= @client.change_examination_some_node_status(6,current_user)
           change_cross_success = @client.change_examination_some_node_status(9,current_user)
           @client.update_state if change_success || change_cross_success
         end


        flash[:notice] = t("clients.form.update_succeed")
          format.html { redirect_to(client_path(:id => @client.id))  }
          format.xml  { render :xml => @client, :status => :created, :location => @client }
      else
        instance_variable_set("@share_sales_client_ids",params[:share_client])
        @name = (Client.all.collect{|c|c.clientname}).uniq
        @client.errors.add(:share_client_blank, t("clients.form.client_blank")) unless params[:share_client]
          format.html { render :action => "edit" }
          format.xml  { render :xml => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  def client_examine
    @client = Client.find(params[:id])
    @client.group_ids = params[:client][:group_ids]
    if @client.save(:validate=>false)
      flash[:notice] = t("clients.form.update_group_succeed")
      redirect_to :action=>"index"
    end
  end




  def delete_client
    @client=Client.find(params[:id])
    @client.delete
    respond_to do |format|
      format.html {
        flash[:notice] = t("clients.form.delete_succeed")
        redirect_to(:action=>"index")
      }
      format.xml { head :ok }
    end
  end

  def check_client
    @client = Client.find(params[:id]) if params[:id] != ""
    @business_opp = Order.options_for_opportunity_id(current_user,order_id = nil,params[:id]) if params[:id] != "" && params[:opp_number] == "0"
    client_currency = @client.currency_id.present? ? (Currency.find @client.currency_id).name : "RMB"
    render :json => {:client_currency => client_currency,:linkman_name =>@client ? @client.clientcontact : "",:linkman_tel=>@client ? @client.clientphone : "",:channel_id => ( @client && (@client.channel == @client.channel.to_i.to_s) ) ? @client.channel.to_i : "",:business_opp => @business_opp.present? ? @business_opp : '' }
  end

  # def master_message
  #   render :text => Client.master_message(params[:name],params[:brand],params[:whether_channel],params[:created_user], current_user)
  # end

  def download
    clients = Client.with_sale_clients(current_user.id,nil,params[:date_range])
    tmp_directory = File.join(Rails.root,"tmp/datas/")
    tmp_filename = "clients"+"_#{DateTime.now.to_i}.xlsx"

    %x(rm -rf #{tmp_directory}/*)
    
    send_clients_xlsx(clients,tmp_directory,tmp_filename)
    begin
      send_file File.join(tmp_directory,tmp_filename)
    rescue
      flash[:notice]= t("clients.form.download_clients_error")
    end
  end

  def ajax_client_node_message
      client =  Client.find (params[:client_id])
      node_ids = params[:node_id].split(",").uniq || []
      status = Client.with_sale_clients(current_user.id,client.id).last["status"].split(",") rescue []
      status = status.push("0") if  status.size == 1
      p 11111111111
      p status
      render :partial => "client_commit_approval_message",:locals => {:client=>client,:node_ids=>node_ids,:status=>status,:whether_cross_district=>params[:whether_cross_district]}
  end

#客户审批api
  def client_approval_from_pms
    node_id =  (params[:node_id]=="9" && params[:common_aproved] == "unapproved")  ? "" : params[:node_id]
    params_list = {:id=>params[:id],:status=>params[:status],:node_id=> node_id,:approver => params[:approver],:comment => params[:comment],:common_aproved => params[:common_aproved],:local_language => params[:local_language],:nodename=>'client_approval'}
    begin
    deal_client_approval(params_list)
    success = @approve_message.present? ? false : true
      return render :json=> {success: success,reason:@approve_message}
    rescue => e
      # p 11111111111
      # p e.to_s
      return render :json=> {success: false,reason: nil}
    end
  end


  def send_client_approval
    deal_client_approval(params[:list])
    p @approve_message
    render :json=> {msg:@approve_message,status:@status,color_class:@color_class,client_state:@client_state,state:@state}
  end

  def deal_client_approval(params)
    #节点标签
    p params
    methodname = params[:nodename]
    p methodname
    node = Node.find_by_actionname(methodname)
    @approve_message = ""
    @status = ""
    @color_class = ""
    @client_state =""
    @state = ""
    if node
      #模型
      @client = Client.find(params[:id])
      I18n.locale = params[:local_language].present? ? params[:local_language].to_sym : I18n.locale
      #节点状态
      status = params[:status]
      #是否有当前操作权限? params["node_id"].precent?
      #注意当角色为admin的时候UI上应该全部params["node_id"]都拥有

      if params[:node_id].present? || status == "1"

        p '0000000000000000'
        comment = params[:comment]
        position = params[:position]


        #当前用户ID
        @client.approver = params[:approver].present? ? params[:approver].to_i : current_user
        current_user = @client.approver


        client_status =  Client.with_sale_clients(current_user.id,@client.id).last["status"].split(",") rescue [] #当前客户两个审批流的状态 "0,0"
        client_status = client_status.push("0") if client_status.size == 1 #客户两个流是顺序操作，所以当跨区审批未操作时补0
        approval,from_state,to_state,@color_class = @client.state_by_approval_or_cross_approval(status,client_status) #客户状态

        p "********:position:#{to_state}"
        @client.state = to_state

        if !@client.save ||  @client.share_clients.blank?

          html = ""
          submit_tip = position == "client_show_page" ? t("clients.index.client_commit_tip2") : t("clients.index.client_commit_tip1",:name=>@client.clientname,:edit_client_url=>edit_client_path(:id=>@client.id,:submit_to_edit=>true))
          html << %Q(<div id="error_explanation" class="error sticker">
                <h2 style="font-size:20px;">#{submit_tip}</h2>
                <ul>)

          @client.errors.add(:share_client_blank, I18n.t("clients.form.client_blank")) if @client.share_clients.blank?
          @client.errors.full_messages.each do |msg|
            html << %Q(<li>#{msg}</li>)
          end
          html << %Q(</ul>
               </div>)
          return @approve_message  = html
        end
        @state = to_state
        @client_state = to_state.present? ?  t("clients.index."+to_state) : ""

        local_language = params[:local_language].present? ? params[:local_language] : I18n.locale.to_s



        # 客户邮件审批申请,客户审批回复邮件
        node_id = status == "1" ?  node.id : params[:node_id]
        if status == "1" #提交给销售总监审批人
          approval_groups = @client.approval_groups(6)
        end

        if status == "2" && @client.whether_cross_district?  #客户支持跨区审批
          approval_groups = @client.approval_groups(9) if @client.state == "cross_unapproved" #总监审批通过时
        end

        examination = Examination.create :node_id => node_id,
                                         :created_user => @client.approver.nil? ? "" : @client.approver.name,
                                         :comment => comment,
                                         :status => status,
                                         :approval => approval,
                                         :from_state =>from_state,
                                         :to_state => to_state,
                                         :examinable_id => @client.id,
                                         :examinable_type => node.model,
                                         :language => local_language
        ClientWorker.perform_async(@client.id,examination.id,status,approval_groups,local_language,current_user.id)
        @status = status
        # @approve_message = methodname+status#I18n.t(methodname+status)
      else
        #可以审批该客户的群组
        # groups = Group.where({"id" => approval_flows.map(&:approval_group)}).map(&:group_name).join(",")
        if params[:common_aproved] == "unapproved"
          @approve_message = %Q(<div id="error_explanation" class="error sticker">#{t("clients.form.approve_notice2")}</div>)

        else
          @approve_message = %Q(<div id="error_explanation" class="error sticker">#{t("clients.form.approve_notice")}</div>)
        end
      end
    else
      super
    end
  end

end
