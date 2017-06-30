class ClientsController < ApplicationController

  include SendAxlsx

  before_filter :left_tab, :only => [:index]

  before_action :api_authenticate, :only => [:client_approval_from_pms]

  skip_before_filter :verify_authenticity_token, :only => [:send_client_approval, :ajax_client_node_message]

  load_and_authorize_resource :only => [:edit, :update]

  share_sales_services :client

  def index
  end

  def loading_all
    @clients = Client.with_sale_clients(current_user.id, nil, params[:date_range])
    @all_share_clients = ShareClient.all_share_clients
    render :partial => 'index', :locals => {clients: @clients, all_share_clients: @all_share_clients}
  end

  def show
    @client = Client.find(params[:id])
    @node_id = params[:node_id]
    #设置销售人员给@share_sales_client_ids
    share_sales_read_clients(@client.id)
  end

  def new
    @client = Client.new(code: Client.create_sn)
    @tag = t('clients.form.new_client')
  end

  def edit
    @client = Client.find(params[:id])
    @node_id = params[:node_id]
    #设置销售人员给@share_sales_client_ids
    share_sales_read_clients(@client.id)
    @client.valid? if params[:submit_to_edit]
    @tag = t('clients.form.edit_client')
  end

  def create
    params.permit!
    @client = Client.new_client_by_user(params, current_user)
    respond_to do |format|
      share_client = params[:share_client]
      if share_client && @client.save
        flash[:notice] = t('clients.form.client_created')
        format.html { redirect_to(client_path(:id => @client.id)) }
        format.xml { render :xml => @client, :status => :created, :location => @client }
      else
        instance_variable_set(:@share_sales_client_ids, share_client)
        @client.errors.add(:share_client_blank, t('clients.form.client_blank')) unless share_client
        format.html { render :new }
        format.xml { render :xml => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    params.permit!
    @client = Client.find(params[:id])
    @client.attributes = params[:client]
    share_client = params[:share_client]
    respond_to do |format|
      if share_client && @client.save
        @client.save_share_clients(share_client)
        if @client.state == 'cli_rejected'
          change_success= @client.change_examination_some_node_status(6, current_user)
          change_cross_success = @client.change_examination_some_node_status(9, current_user)
          @client.update_state if change_success || change_cross_success
        end
        flash[:notice] = t('clients.form.update_succeed')
        format.html { redirect_to(client_path(:id => @client.id)) }
        format.xml { render :xml => @client, :status => :created, :location => @client }
      else
        instance_variable_set(:@share_sales_client_ids, share_client)
        @client.errors.add(:share_client_blank, t('clients.form.client_blank')) unless share_client
        format.html { render :edit }
        format.xml { render :xml => @client.errors, :status => :unprocessable_entity }
      end
    end
  end

  def client_examine
    @client = Client.find(params[:id])
    @client.group_ids = params[:client][:group_ids]
    if @client.save(:validate => false)
      flash[:notice] = t('clients.form.update_group_succeed')
      redirect_to action: :index
    end
  end


  def delete_client
    @client=Client.find(params[:id])
    @client.delete
    respond_to do |format|
      format.html {
        flash[:notice] = t('clients.form.delete_succeed')
        redirect_to action: :index
      }
      format.xml { head :ok }
    end
  end

  def check_client
    @client = Client.find(params[:id]) rescue nil
    @business_opp = Order.options_for_opportunity_id(current_user, order_id = nil, params[:id]) if params[:id] != '' && params[:opp_number] == '0'
    client_currency = @client.c_currency_name
    render :json => {:client_currency => client_currency, :linkman_name => @client.clientcontact.to_s, :linkman_tel => @clientclientphone.to_s, :channel_id => @client.channel.to_i, :business_opp => @business_opp}
  end


  def download
    clients = Client.with_sale_clients(current_user.id, nil, params[:date_range])
    tmp_directory = File.join(Rails.root, 'tmp/datas/')
    tmp_filename = "clients_#{DateTime.now.to_i}.xlsx"
    %x(rm -rf #{tmp_directory}/*)
    send_clients_xlsx(clients, tmp_directory, tmp_filename)
    begin
      send_file File.join(tmp_directory, tmp_filename)
    rescue
      flash[:notice]= t('clients.form.download_clients_error')
    end
  end

  def ajax_client_node_message
    client = Client.find (params[:client_id])
    node_ids = params[:node_id].split(',').uniq || []
    status = Client.with_sale_clients(current_user.id, client.id).last['status'].split(',') rescue []
    status = status.push('0') if status.size == 1
    render :partial => 'client_commit_approval_message', :locals => {client: client, node_ids: node_ids, status: status, whether_cross_district: params[:whether_cross_district]}
  end

#客户审批api
  def client_approval_from_pms
    node_id = (params[:node_id]== '9' && params[:common_aproved] == 'unapproved') ? '' : params[:node_id]
    params_list = {:id => params[:id], :status => params[:status], :node_id => node_id, :approver => params[:approver], :comment => params[:comment], :common_aproved => params[:common_aproved], :local_language => params[:local_language], :nodename => 'client_approval'}
    begin
      deal_client_approval(params_list)
      success = @approve_message.present? ? false : true
      return render :json => {success: success, reason: @approve_message}
    rescue => e
      return render :json => {success: false, reason: nil}
    end
  end


  def send_client_approval
    @client = Client.find params[:list][:id]
    approve_message, status, color_class, client_state, state = @client.deal_client_approval(params[:list], current_user)
    render :json => {msg: approve_message.to_s,
                     status: status.to_s,
                     color_class: color_class.to_s,
                     client_state: client_state.to_s,
                     state: state.to_s}
  end

end
