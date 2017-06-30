class ProductsController < ApplicationController
  include SendDataAxlsx
  before_filter :left_tab, :only => [:index]
  load_and_authorize_resource :only => ["index","show","create","edit","update"]
  def index
   @products = Product.where("is_delete = ? ",false).order(updated_at: :desc)
   @targ = "产品列表"
  end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(params[:product])
    product_category = ProductCategory.find params[:product][:product_category_id]
    @product.product_type = product_category.value
    @product.product_type_cn = product_category.name
    @product.product_type_en = product_category.en_name
    @product.floor_discount = params[:product][:floor_discount].present? ?  params[:product][:floor_discount].to_f / 100  : nil
    respond_to do |format|
      if  @product.save
        flash[:notice] = t('order.form.product_create_success_tip')
        format.html { redirect_to products_path }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  def show
   @product = Product.find(params[:id])
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product_ori = Product.find(params[:id])
    @product_ori.is_delete = true
    @product_ori.parent_id =  params[:id] if @product_ori.parent_id.nil?
    @product_new = Product.new(params[:product])
    product_category = ProductCategory.find params[:product][:product_category_id]
    @product_new.product_type = product_category.value
    @product_new.product_type_cn = product_category.name
    @product_new.product_type_en = product_category.en_name
    @product_new.floor_discount = params[:product][:floor_discount].present? ?  params[:product][:floor_discount].to_f / 100 : nil
    @product_new.parent_id = @product_ori.parent_id.nil? ? @product_ori.id : @product_ori.parent_id
    respond_to do |format|
      if @product_ori.save(:validate=>false) && @product_new.save
        BusinessOpportunityProduct.where({"product_id"=> @product_ori.id}).update_all(product_id: @product_new.id)
        flash[:notice] = t('order.form.product_update_success_tip')
        format.html { redirect_to products_path }
        format.xml  { render :xml => @product_new, :status => :created, :location => @product_new }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @product_new.errors, :status => :unprocessable_entity }
      end
    end
  end

  def download
    products = Product.where("is_delete = ? ",false).order(updated_at: :desc)
    tmp_directory = File.join(Rails.root,"tmp/datas/")
    tmp_filename = "products"+"_#{DateTime.now.to_i}.xlsx"

    %x(rm -rf #{tmp_directory}/*)

    send_products_xlsx(products,tmp_directory,tmp_filename)
    begin
      send_file File.join(tmp_directory,tmp_filename)
    rescue
      flash[:notice]= t("products.index.download_products_error")
    end
  end

  def delete_product
    @product = Product.find(params[:id])
    respond_to do |format|
      if @product.update_column(:is_delete,'1')
        flash[:notice] = t("products.tips.p_delete_success")
        format.html { redirect_to products_path }
        format.xml  { render :xml => @product, :status => :created, :location => @product }
      else
        flash[:notice] = t("products.tips.p_delete_fail")
        format.html { render :action => "index" }
        format.xml  { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

  private

  def product_params
    params.require(:product).permit(:product_serial,:name,:en_name,:product_category_id,:financial_settlement_id,:product_regional_id,:sale_model,:public_price,:currency,:floor_discount,:ctr_prediction,:gp,:is_distribute_gp,:product_gp_type,:product_xmo_type,:remark,:bu=>[])
  end


end
