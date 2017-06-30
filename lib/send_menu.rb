module SendMenu

  # ReturnXmoUrl = "http://localhost:3000"
  # ReturnXmoUrls = "http://localhost:3000"
  if Rails.env.production?
    ReturnXmoUrl = "http://xmo.optimix.asia"
    ReturnXmoUrls = "https://xmo.optimix.asia"
    DbConnection = "sales_booking_production"
  else
    ReturnXmoUrl = "http://xmodev1.optimix.asia"
    ReturnXmoUrls = "https://xmodev1.optimix.asia"
    DbConnection = "sales_booking_production"
  end

  XomIp = ["210.5.172.216"]

  SiteTabs = %w[left right]
  SiteTabs.each { |m| define_method("#{m}_tab") {session["#{m}_tab".to_sym] = request.path} }

  SiteTabs.each do |m|
    define_method("#{m}_title_select") do |*arg|
      title,link = arg[0],arg[1]
      title_select title,link,session["#{m}_tab".to_sym],m
    end
  end


  def title_select(tab_title,link,sess,m)
    selected = link != sess ? "" : "selected"
    if m == "left" && session[:left_tab]
      raw "<li class='#{selected}'><a href='#{link}'>#{tab_title}</a></li>"
    else
      raw "<li class='#{selected}'><a href='#{link}'>#{tab_title}</a></li>"
    end
  end

  def check_action_name
    if session[:left_tab]
      if session[:left_tab].include?("un")
        session[:left_tab].gsub("un","")
      else
        session[:left_tab]
      end
    else
      if self.controller_name == "orders"
        approved_orders_path
      elsif self.controller_name == "clients"
        approved_clients_path
      end
    end
  end

  def uncheck_action_name
    if session[:left_tab]
      if session[:left_tab].include?("un")
        session[:left_tab]
      else
        a = session[:left_tab].split("/")
        a[-1] = "un"<<a.last
        a.join("/")
      end
    else
      if self.controller_name == "orders"
        approved_orders_path
      elsif self.controller_name == "clients"
        approved_clients_path
      end
    end
  end

  def can_edit_action?
    %w(new edit update create).include? action_name
  end

  def current_user
    @current_user ||= login_from_session  unless @current_user == false
  end

  def current_user=(new_user)
    session[:user_id] = new_user ? new_user.id : nil
    @current_user = new_user || false
  end

  def login_from_session
    self.current_user = User.find_by_id(session[:user_id]) if session[:user_id]
  end

  #找出当前用户能看到的BU产品
  #[["请选择",""]]+
  def all_ad_types
    @all_ad_types = []
   # @all_product_types = current_user.self_bu_adtype_new-["其他","OTHERTYPE"]
    @all_product_types = current_user.self_bu_adtype_new
    @all_product_types.each do |product_type|
        @all_ad_types << [product_type[1],current_user.self_bu_adcombo_new(product_type[1])]
    end
  end

  def return_gp_img(gp_rake)
    min,max = @order.unstandard_range
    gp_img = "icon02_red.png"
    gp_text = t("order.form.to_be_improved_immediately2")

    if ( gp_rake*100 < min)
        gp_img = "icon02_red.png"
        gp_text = t("order.form.to_be_improved_immediately2")
    elsif (min <= gp_rake*100 &&  gp_rake*100<= max)
        gp_img = "icon03_orange.png"
        gp_text = t("order.form.yet_to_improve_gp2")
    elsif   gp_rake*100 > max
        gp_img = "icon05_green.png"
        gp_text = t("order.form.gp_meet_standard2")
    end
    return "<img src='/images/assets/#{gp_img}'/>" + " " + "#{gp_text}"
  end




  #more extend class method for order and client

  def self.included(recipient)
    recipient.extend(ModelClassMethods)
  end

  module ModelClassMethods

    def sync_attributes_services(me_name,system="SAP")
      class_name = me_name.to_s.camelize.constantize

      #获取类拓展属性
      define_method("sync_attributes_#{me_name}s") do
        instance_variable_set("@sync_attributes_#{me_name}s",SyncAttribute.where("type = ? and system = ?",me_name,system).map(&:en) )
      end

      #保存类拓展属性
      define_method("sync_attributes_save_#{me_name}s") do
        @cate = class_name.find(params[:id])
        attribute_value_mode = (me_name.to_s.camelize+"AttributeValue").constantize
        attribute_value_mode.where("#{me_name}_id = ? ",params[:id]).each{|att| att.delete }
        SyncAttribute.where("type = ? and system = ?",me_name,system).each do |sttr_name|
          @attribute_value_mode = attribute_value_mode.new
          @attribute_value_mode["value"] = params["#{sttr_name[:en]}"].present? ? params["#{sttr_name[:en]}"].class == Array ?  (params["#{sttr_name[:en]}"]).join("|") :(params["#{sttr_name[:en]}"]) :""
          @attribute_value_mode["attribute_en_name"] = sttr_name[:en]
          @attribute_value_mode["system"] = sttr_name[:system]
          @attribute_value_mode["attribute_id"] = sttr_name[:id]
          @attribute_value_mode["#{me_name}_id"] = @cate.id
          @attribute_value_mode.save!
        end
      end

      #查询类拓展属性值数组
      define_method("sync_attributes_read_#{me_name}s") do
        if params[:id]
          @cate = class_name.find(params[:id])
          @attribute_values = @cate.send("#{me_name}_attribute_values").collect{|val|[val.attribute_en_name,val.value]}
          instance_variable_set("@sync_attributes_#{me_name}_values",@attribute_values)
          unless me_name.to_s == "channel"
            share_model = ("Share"+me_name.to_s.camelize).constantize
            share_ids = share_model.where("#{me_name}_id = ?",params[:id].to_i).map(&:share_id)
            instance_variable_set("@share_sales_#{me_name}_ids",share_ids)
          end
        end
      end

      #共享销售保存
      define_method("update_share_#{me_name}s") do
        @cate = class_name.find(params[:id])
        share_model = ("Share"+me_name.to_s.camelize).constantize
        ids = share_model.where("#{me_name}_id = ?",@cate.id).pluck(:id)
        share_model.delete(ids)
        if params["share_#{me_name}"]
          params["share_#{me_name}"].each do |share_id|
            @share_model = share_model.new()
            @share_model["#{me_name}_id"] = @cate.id
            @share_model.share_id = share_id
            @share_model.save
          end
        end
      end

    end

  end

end