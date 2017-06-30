class ProductTypesController < ApplicationController
  before_action :set_product_type, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @product_types = ProductType.all
    respond_with(@product_types)
  end

  def show
    respond_with(@product_type)
  end

  def new
    @product_type = ProductType.new
    @id=params[:id]
  end

  def edit
  end

  def create
    @product_type = ProductType.new(product_type_params)

    offer_action=params[:offer_id].blank? ? new_offer_path : edit_offer_path(params[:offer_id])
    respond_to do |format|
        if  @product_type.save
          flash[:notice] = t('order.form.product_type_create_success_tip')
          format.html { redirect_to offer_action}
          #format.html { redirect_to(@client) }
          format.xml  { render :xml => @product_type, :status => :created, :location => @product_type }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @product_type.errors, :status => :unprocessable_entity }
        end
    end
    end

  def update
    @product_type.update(product_type_params)
    respond_with(@product_type)
  end

  def destroy
    @product_type.destroy
    respond_with(@product_type)
  end

  private
    def set_product_type
      @product_type = ProductType.find(params[:id])
    end

    def product_type_params
      params.require(:product_type).permit(:name, :ad_platform, :ad_type)
    end
end
