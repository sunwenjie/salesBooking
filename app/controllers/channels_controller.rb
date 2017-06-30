class ChannelsController < ApplicationController
  include SendMenu
  include SendDataAxlsx
  before_filter :left_tab, :only => [:index]
  # sync_attributes_services :channel
  load_and_authorize_resource :only => ["index","show","create","edit","update"]

  def index
  end

  def loading_all

    @channel = Channel.with_sale_agencies(current_user)
    render :partial => "index", :locals => {:channel => @channel}
  end

  def is_cancel_examine
   @channel = Channel.find_by_id params[:id]
   @channel.is_cancel_examine = params[:examine]
   @channel.save
   render :xml => @channel, :status => :created, :location => @channel
  end
  
  def show
    @channel = Channel.find(params[:id])
  end

  def new
    @channel = Channel.new
    @tag = "新增渠道"
  end

  def edit
    @channel = Channel.find(params[:id])
  end

  def create
    @channel = Channel.new(params[:channel])
    all_nonuniforms_date_range = params.select{|k,v| k =~ /^nonuniform_date_range(\d+|)$/ && v.strip != "" }
    all_nonuniform_rebate = params.select{|k,v| k =~ /^nonuniform_rebate(\d+|)$/ && v.strip != "" }
    @channel.all_nonuniforms_date_range = all_nonuniforms_date_range
    @channel.all_nonuniform_rebate = all_nonuniform_rebate

    respond_to do |format|
      if @channel.save
        ChannelRebate.insert_channel_rebate(@channel.id,all_nonuniforms_date_range,all_nonuniform_rebate) if all_nonuniforms_date_range.present? && all_nonuniform_rebate.present?
        flash[:notice] = t("products.tips.create_success")
          format.html { redirect_to channels_path }
          format.xml  { render :xml => @channel, :status => :created, :location => @channel }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @channel = Channel.find(params[:id])
    # sync_attributes_save_channels
    all_nonuniforms_date_range = params.select{|k,v| k =~ /^nonuniform_date_range(\d+|)$/ && v.strip != ""}
    all_nonuniform_rebate = params.select{|k,v| k =~ /^nonuniform_rebate(\d+|)$/ && v.strip != "" }
    @channel.all_nonuniforms_date_range = all_nonuniforms_date_range
    @channel.all_nonuniform_rebate = all_nonuniform_rebate
     @channel.attributes = params[:channel]
    respond_to do |format|
        if  @channel.save && @channel.update_attributes(channel_params)
          @channel.channel_rebates.delete_all
          ChannelRebate.insert_channel_rebate(@channel.id,all_nonuniforms_date_range,all_nonuniform_rebate) if all_nonuniforms_date_range.present? && all_nonuniform_rebate.present?

          flash[:notice] = t("products.tips.update_success")
            format.html { redirect_to channels_path }
            format.xml  { render :xml => @channel, :status => :created, :location => @channel }
          else
            format.html { render :action => "edit" }
            format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
        end
      end
  end

  def deleted
    @channel = Channel.find(params[:id])
    respond_to do |format|
      if @channel.update_column(:is_delete,'1')
        flash[:notice] = t("products.tips.delete_success")
          format.html { redirect_to channels_path }
          format.xml  { render :xml => @channel, :status => :created, :location => @channel }
        else
          flash[:notice] = t("products.tips.delete_fail")
          format.html { render :action => "index" }
          format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  def ajax_save_sync_flag_channel
    channel_id = params[:channel_id]
    @channel = Channel.find(channel_id)
    @channel.sync_flag = 0
    if  @channel.save!
      render :json => {:suncess => "success"}
    end

  end

  def download
    agencies = Channel.with_sale_agencies(current_user)
    tmp_directory = File.join(Rails.root,"tmp/datas/")
    tmp_filename = "agencies"+"_#{DateTime.now.to_i}.xlsx"

    %x(rm -rf #{tmp_directory}/*)

    send_agencies_xlsx(agencies,tmp_directory,tmp_filename)
    begin
      send_file File.join(tmp_directory,tmp_filename)
    rescue
      flash[:notice]= t("products.index.download_agencies_error")
    end
  end

  private

  def channel_params
      params.require(:channel).permit(:channel_name,:is_cancel_examine,:qualification_name,:currency_id,:contact_person,:phone,:email,:position,:company_adress,:rebate,:user_ids => [])
  end



end
