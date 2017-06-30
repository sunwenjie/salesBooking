class EventsController < ApplicationController

  before_filter :right_tab
  before_filter :left_tab, :only => [:index]


  def index
    # notify_emails=Event.event_user_emails("notify_sale_with_client_same_channel","sale")
    # p "**********notify_emails:"+notify_emails.to_s
    @events = Event.all
    left_tab
    @targ = "事件通知列表"
  end

  def show
    @event = Event.find(params[:id])
  end

  def new
    @event = Event.new
  end

  def edit
    @event=Event.find(params[:id])
    @targ="事件通知修改"
  end

  def create

  end

  def update
    params.permit!
    @event = Event.find(params[:id])
    params[:event][:group_ids]=[] if params[:event][:group_ids].nil?
    params[:event][:user_ids]=[] if params[:event][:user_ids].nil?
    respond_to do |format|
      if @event.update_attributes(params[:event])

        flash[:notice] = t('order.form.event_tips')
        format.html { redirect_to(:action => "index") }
        format.xml { render :xml => @event, :status => :created, :location => @event }
      else
        format.html { render :action => "edit" }
        format.xml { render :xml => @event.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @event.destroy
    respond_with(@event)
  end

  private

  def event_params
    params.require(:event).permit(:name, :notify_type, :event_type, :group_ids => [], :user_ids => [])
  end

end
