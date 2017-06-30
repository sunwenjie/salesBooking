class ProductsController < ApplicationController

  include SendAxlsx

  before_filter :left_tab, :only => [:index]
  load_and_authorize_resource :only => [:index,:show,:edit,:update]

  def index
    @products = Product.where({is_delete: false}).order(updated_at: :desc).includes(:financial_settlement)
  end

  def new
    @product = Product.new
  end

  def create
    params.permit!
    @product = Product.new_product(params)
    respond_to do |format|
      if @product.save
        flash[:notice] = t('order.form.product_create_success_tip')
        format.html { redirect_to products_path }
        format.xml { render :xml => @product, :status => :created, :location => @product }
      else
        format.html { render :new }
        format.xml { render :xml => @product.errors, :status => :unprocessable_entity }
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
    params.permit!
    @product_ori = Product.find(params[:id])
    @product_ori.is_delete = true
    @product_ori.parent_id = params[:id] if @product_ori.parent_id.nil?
    @product_new = Product.new_product(params)
    @product_new.parent_id = @product_ori.parent_id.nil? ? @product_ori.id : @product_ori.parent_id
    respond_to do |format|
      if @product_ori.save(:validate => false) && @product_new.save
        #更新商机产品id
        BusinessOpportunityProduct.update_product_id(@product_ori, @product_new)
        flash[:notice] = t('order.form.product_update_success_tip')
        format.html { redirect_to products_path }
        format.xml { render :xml => @product_new, :status => :created, :location => @product_new }
      else
        format.html { render :edit }
        format.xml { render :xml => @product_new.errors, :status => :unprocessable_entity }
      end
    end
  end

  def download
    products = Product.where({is_delete: false}).order(updated_at: :desc)
    tmp_directory = File.join(Rails.root, "tmp/datas/")
    tmp_filename = "products_#{DateTime.now.to_i}.xlsx"

    %x(rm -rf #{tmp_directory}/*)

    send_products_xlsx(products, tmp_directory, tmp_filename)
    begin
      send_file File.join(tmp_directory, tmp_filename)
    rescue
      flash[:notice]= t('products.index.download_products_error')
    end
  end

  def delete_product
    @product = Product.find(params[:id])
    respond_to do |format|
      if @product.update_attribute(:is_delete, true)
        flash[:notice] = t('products.tips.p_delete_success')
        format.html { redirect_to products_path }
        format.xml { render :xml => @product, :status => :created, :location => @product }
      else
        flash[:notice] = t('products.tips.p_delete_fail')
        format.html { render :index }
        format.xml { render :xml => @product.errors, :status => :unprocessable_entity }
      end
    end
  end

end
