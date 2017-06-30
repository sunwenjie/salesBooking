class OffersController < ApplicationController
  before_filter :left_tab, :only => [:index]
  def index
    @offers=Offer.where(is_delete: false).order(updated_at: :desc)
    @targ = "汇率列表"
  end

  def new
    @offer=Offer.new
  end


  def create
    @offer=Offer.new(offer_params)
    offer=Offer.where("regional=? and ad_platform=? and ad_type=? and public_price = ? and general_discount like ? and floor_discount like ?  and ctr_prediction like ?",offer_params[:regional],offer_params[:ad_platform],offer_params[:ad_type],offer_params[:public_price],offer_params[:general_discount],offer_params[:floor_discount],offer_params[:ctr_prediction]).exists?
    respond_to do |format|
      unless  offer
        if  @offer.save
        flash[:notice] = t('order.form.exchange_rate_success_tip')
        format.html { redirect_to offers_path }
        #format.html { redirect_to(@client) }
        format.xml  { render :xml => @offer, :status => :created, :location => @offer }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
        end
      else
        flash[:notice] = t('order.form.exchange_rate_failed_tip')
        format.html { render :action => "new" }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end

  end

  def update
    @offer = Offer.find_by_id params[:id]
    @offer.is_delete=true
    @offer_new=Offer.new(offer_params)
    respond_to do |format|
      if  @offer.save && @offer_new.save
        flash[:notice] = t('order.form.exchange_rate_update_success_tip')
        format.html { redirect_to offers_path }
        #format.html { redirect_to(@client) }
        format.xml  { render :xml => @offer, :status => :created, :location => @offer }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @offer.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    @offer = Offer.find_by_id params[:id]
  end


  def delete_offer
    @offer=Offer.find(params[:id])
    @offer.is_delete=true
    respond_to do |format|
      if @offer.save
      format.html {
        flash[:notice] = t('order.form.exchange_rate_del_success_tip')
        redirect_to(:action=>"index")
      }
      format.xml { head :ok }
      else
        format.html {
          flash[:notice] = t('order.form.exchange_rate_del_failed_tip')
        }
      end
    end
  end

  private

  def offer_params
    params.require(:offer).permit(:ad_platform, :ad_type, :public_price,:regional,:general_discount,:floor_discount,:ctr_prediction,:currency,:is_delete)
  end

end
