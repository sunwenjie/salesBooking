class AdvertisementsController < ApplicationController
  #新增advertisement
  def new
    @advertisement = Advertisement.new
    render partial: 'orders/advertisement_form', locals: {flag: 'new'}
  end

  #创建新增advertisement
  def create
    params.permit!
    advertisement_admeasure(params)
    @advertisement = Advertisement.new(params[:advertisement])
    respond_to do |format|
      if @advertisement.save(validate: false)
        flash.now[:notice] = t('order.form.save_advertisement_success_tip')
        format.html { render :partial => 'orders/order_advertisements', :locals => {:key_word_update => true} }
        format.xml { render :xml => @advertisement, :status => :created, :location => @advertisement }
      else
        format.html { render :new }
        format.xml { render :xml => @advertisement.errors, :status => :unprocessable_entity }
      end
    end
  end

  #编辑advertisement
  def edit
    @advertisement = Advertisement.find params[:id]
    render :partial => 'orders/advertisement_form', :locals => {:flag => params[:flag]}
  end

  #修改advertisement
  def update
    params.permit!
    advertisement_admeasure(params)
    @advertisement = Advertisement.find params[:ad_id]
    origin_ad = Advertisement.new(@advertisement.attributes.dup)
    respond_to do |format|
      if @advertisement.update_attributes(params[:advertisement])
        flash.now[:notice] = t('order.form.update_advertisement_success_tip')
        key_word_update = @advertisement.update_ad_examinations_status?(origin_ad, current_user)
        format.html { render :partial => 'orders/order_advertisements', :locals => {:key_word_update => key_word_update} }
        format.xml { render :xml => @advertisement, :status => :created, :location => @advertisement }
      else
        format.html { render :edit }
        format.xml { render :xml => @advertisement.errors, :status => :unprocessable_entity }
      end
    end
  end



  private

  def advertisement_admeasure(params)
    if params[:advertisement][:admeasure_state] && params[:ad][:mycity]
      admeasure = []
      params[:ad][:mycity].each_with_index { |city, i|
        admeasure << [city, params[:ad][:myplanner][i].gsub(/,/, '')]
      }
      admeasure <<[params[:ad][:all_mycity], params[:ad][:all_myplanner].gsub(/,/, '')]
      if I18n.locale.to_s == 'en'
        params[:advertisement][:admeasure_en] = admeasure
        params[:advertisement][:admeasure] = translate_admeasure(admeasure)
      else
        params[:advertisement][:admeasure] = admeasure
        params[:advertisement][:admeasure_en] = translate_admeasure(admeasure)
      end
    else
      params[:advertisement][:admeasure_state] = nil
      params[:advertisement][:admeasure_en] = nil
      params[:advertisement][:admeasure] = nil
    end
    params[:advertisement][:product_id] = params[:advertisement][:ad_type] == 'OTHERTYPE' ? Product.where("is_delete = false and product_type = 'OTHERTYPE'").last.id : params[:advertisement][:product_id]

    return params
  end

  def translate_admeasure(admeasure_org)
    admeasure = admeasure_org[0..-2]
    admeasure_region = admeasure.map { |x| "'"+x[0].gsub(/\'/, "''") +"'" }.join(",")
    cities = LocationCode.cities_by_name(admeasure_region)
    cities_en = cities.map { |city| [city['city_name'], city['city_name_cn']] }.to_h
    cities_cn = cities_en.invert
    admeasure_t = admeasure.map { |a|
      [I18n.locale.to_s == 'en' ? cities_en[a[0]] : cities_cn[a[0]], a[1]]
    }
    admeasure_t << [I18n.locale.to_s == 'en' ? '全部' : 'All', admeasure_org[-1][1]]
  end

end
