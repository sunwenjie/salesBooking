class ChannelsController < ApplicationController

  include SendAxlsx

  before_filter :left_tab, :only => [:index]
  load_and_authorize_resource :only => [:index, :show, :create, :edit, :update]

  def index
  end

  def loading_all

    @channel = Channel.with_sale_agencies(current_user)
    render :partial => 'index', :locals => {:channel => @channel}
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
  end

  def edit
    @channel = Channel.find(params[:id])
  end

  def create
    @channel = Channel.new_channel(params)
    respond_to do |format|
      if @channel.save
        @channel.insert_channel_rebate
        flash[:notice] = t('products.tips.create_success')
        format.html { redirect_to channels_path }
        format.xml { render :xml => @channel, :status => :created, :location => @channel }
      else
        format.html { render :new }
        format.xml { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @channel = Channel.find(params[:id])
    @channel.all_nonuniforms_date_range, @channel.all_nonuniform_rebate = Channel.rebate_array(params)
    @channel.user_ids = params[:channel][:user_ids] ? params[:channel][:user_ids] : nil
    respond_to do |format|
      if @channel.update_attributes(channel_params)
        @channel.insert_channel_rebate
        flash[:notice] = t('products.tips.update_success')
        format.html { redirect_to channels_path }
        format.xml { render :xml => @channel, :status => :created, :location => @channel }
      else
        format.html { render :edit }
        format.xml { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  def deleted
    @channel = Channel.find(params[:id])
    respond_to do |format|
      if @channel.update_column(:is_delete, '1')
        flash[:notice] = t('products.tips.delete_success')
        format.html { redirect_to channels_path }
        format.xml { render :xml => @channel, :status => :created, :location => @channel }
      else
        flash[:notice] = t('products.tips.delete_fail')
        format.html { render :index }
        format.xml { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end


  def download
    agencies = Channel.with_sale_agencies(current_user)
    tmp_directory = File.join(Rails.root, "tmp/datas/")
    tmp_filename = "agencies_#{DateTime.now.to_i}.xlsx"

    %x(rm -rf #{tmp_directory}/*)

    send_agencies_xlsx(agencies, tmp_directory, tmp_filename)
    begin
      send_file File.join(tmp_directory, tmp_filename)
    rescue
      flash[:notice]= t('products.index.download_agencies_error')
    end
  end

  private

  def channel_params
    params.require(:channel).permit(:channel_name, :is_cancel_examine, :qualification_name, :currency_id, :contact_person, :phone, :email, :position, :company_adress, :rebate, :user_ids => [])
  end


end
