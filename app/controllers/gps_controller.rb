class GpsController < ApplicationController
  #before_action :call_order_and_advertisement
  skip_before_filter :verify_authenticity_token
  include SendDataAxlsx
  def call_order_and_advertisement
    @advertisement = Advertisement.find(params[:gps_attributes].values[0][:advertisement_id])
    @city = params[:gps_attributes].values[0][:city] ? params[:gps_attributes].values[0][:city] : "-"
    @city = Order.map_region_names(true,@city)
    @order = @advertisement.order
  end

  #返回gp指标
  def get_gps
    @advertisement_gps = @advertisement.current_send_gps_rake(Order.map_region_names(true,params[:gps_attributes].values[0][:city]))
    render :text => return_gp_img(@advertisement_gps)
  end

  #gp动态编辑保存
  def ajax_gp_save
    call_order_and_advertisement
    all_advertisement = params[:gps_attributes].values

    all_advertisement.each do |gp|

      if gp[:city] != "-"
        lgp = Gp.where("advertisement_id = ? and media_id = ? and city = ? ",gp[:advertisement_id], gp[:media_id].to_i, Order.map_region_names(true,gp[:city]))
      else
        lgp = Gp.where("advertisement_id = ? and media_id = ? ",gp[:advertisement_id], gp[:media_id].to_i )
      end
      if lgp.present?
        gp[:id] = lgp[0].id
      end
      gp[:city] = Order.map_region_names(true,gp[:city])
    end

    @advertisement.attributes = {:gps_attributes => all_advertisement }
    @advertisement.save!
    get_gps
  end

  #自动分配PV
  def audo_pv_distribution
    call_order_and_advertisement
    if @advertisement.gps.present?
      return_audo_pv = @advertisement.auto_distribution(@city)
      @auto_pv_size = return_audo_pv.size
      @audo_pv = {}
       @pv_config = 0
       @pv_config_scale = 0
      return_audo_pv.each do |pv|
       @audo_pv[pv[0].to_s] = pv[1..-1]
       @pv_config += pv[4]
       @pv_config_scale += pv[3]
      end
    end
      @current_city = @city
      @current_origin_size = params[:origin_size]
      @current_expand_size = params[:expand_size]
      @current_media_type = params[:media_type]
      @check = params[:check]
      @current_type = @advertisement.id
      advertisement_gps = @advertisement.current_send_gps_rake(Order.map_region_names(true,params[:gps_attributes].values[0][:city]))
      @gp_rake = return_gp_img(advertisement_gps)

    render_pv_config_data
  end

  #gp编辑添加按钮保存
  def ajax_input_save
    call_order_and_advertisement
    @gps = @advertisement.current_gps(@city)
    @gps.each do |gp|
      gp.save_flag = true
      gp.gp = gp.get_gp
      gp.save!
    end
    @order.update_columns(:is_gp_finish =>true,:last_update_user => current_user.name,:last_update_time => Time.now)  if  @order.any_not_order_gp_finish?
    # @change_status_flag = @order.change_examination_some_node_status(params[:node_id],current_user) if  params[:status] == "3" && params[:status].present?
    render_pv_config_data
  end

  def ajax_remove_pv_config
    ad =Advertisement.find(params[:ad_id])
    @order = ad.order
    city = params[:city]
    ad.delete_advertisement_gps(city);
    @order.update_columns(:is_gp_finish =>false,:last_update_user => current_user.name,:last_update_time => Time.now)
    # @change_status_flag = @order.change_examination_some_node_status(params[:node_id],current_user) if params[:status] == "3" && params[:status].present?
    render_pv_config_data
  end

  def render_pv_config_data
    # 查找未分配完的地市
    ad = @current_type ? @advertisement : @order.map_gp_advertisements[0]

    if ad.present?

      unless @current_city
        ad.delete_advertisement_unsave_gps
      end
      @city_max_pv=ad.total_cpm_show if !ad.have_admeasure_map?
      @city =  ad.get_advertisement_unfinish_citys
      @origin_size=[]
      @expand_size=[]
      @pv_list_filter = ad.book_sql.present??  PvDetail.find_by_sql(ad.book_sql) : []
      @pv_list_filter.each{|pv|
        @origin_size.push(pv.ad_original_size)if pv.ad_original_size.present?
        @expand_size.push(pv.ad_expand_size) if pv.ad_expand_size.present?
      }
      @origin_size=@origin_size.push("NA").uniq
      @expand_size=@expand_size.push("NA").uniq
      @type = ad.id
    end
    # media_selected_list = Order.get_media_list(@order.id)
    media_selected_list = Gp.get_gp_list(@order.id)
    @data = media_selected_list.group_by(&:advertisement_id)
    render :partial=>"/orders/gp_config"
  end

  def download_gps_list
    order_id = params[:order_id]

    tmp_directory = File.join(Rails.root,"tmp/datas/")
    tmp_filename = random+"_#{DateTime.now.to_i}.xlsx"

    %x(rm -rf #{tmp_directory}/*)

    send_gps_xlsx(order_id,tmp_directory,tmp_filename)
    begin
      send_file File.join(tmp_directory,tmp_filename)
    rescue
      flash[:notice]=t('order.form.download_gp_failed')
    end
  end

  def random
    request_id = ([*('A'..'Z'), *('a'..'z'), *('0'..'9')]-%w(0 1 h I O)).sample(14).join
    return request_id
  end
end
