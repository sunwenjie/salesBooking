class AdminsController < ApplicationController
  before_action :authenticate_user?, :except => [:reset_mail, :login, :logout]
  layout "login_appliction", :only => :reset_mail

  def index
    @users = User.where("user_status != ?", "Paused").preload(:group)
    authorize! :show, current_user
    left_tab
  end

  def login
    return redirect_to orders_path if session and @current_user
    if cookies[:remember_me_id] && User.find(cookies[:remember_me_id]) && Digest::SHA1.hexdigest(User.find(cookies[:remember_me_id]).username) == cookies[:remember_me_code]
      session[:user_id] = User.find(cookies[:remember_me_id]).id
      return redirect_to orders_path
    end

    session[:user_id] = nil

    flash[:error] = t("admin.acount_lockout_wrong_username_or_password") if params[:xmo_reset_password]

    return authenticate if request.post?

    render :layout => false
  end


  def logout
    session[:user_id] = nil
    if cookies[:remember_me_id] then
      cookies.delete :remember_me_id
    end
    if cookies[:remember_me_code] then
      cookies.delete :remember_me_code
    end

    if params[:back_url].nil?
      redirect_to auth_login_path
    else
      redirect_to auth_login_path(back_url: params[:back_url])
    end
  end


  def edit
    @current_user = current_user
    @user = User.find_by_id params[:id]
  end

  def reset_mail

  end

  def error_mail
    @email_to = 'technology@i-click.com'
    render "error_mail", :layout => false
  end


  private

  def authenticate
    user = User.authenticate(params[:username].strip, params[:password].strip)
    if user.nil?
      flash[:error] = t("admin.acount_lockout_wrong_username_or_password")
      return redirect_to login_admins_path
    elsif user.active?
      current_user = user
      session[:user_id] = user.id
      back_url = URI::decode(params[:back_url])
      uri = URI::parse(back_url)
      if params[:remember_me] == '1'
        cookies[:remember_me_id] = {:value => user.id.to_s, :expires => 30.days.from_now}
        userCode = Digest::SHA1.hexdigest(user.username)
        cookies[:remember_me_code] = {:value => userCode, :expires => 30.days.from_now}
      end
      if back_url.to_s == '' or uri.host.nil? or uri.host.to_s != request.host or uri.path.include?('auth/login') or uri.path.include?('admins/logout') or uri.path == "/" or uri.path == ""
        return redirect_to orders_path
      else
        return redirect_to back_url
      end
    else
      if !user.group_active? || user.stopped? || !user.agency.active?
        support_mail = user.support_email
        flash.now[:login_warning] = t('admin.group_paused_message', :click_here => "mailto:#{support_mail}")
      elsif user.paused?
        if user.last_logged_in_at < 1.month.ago
          flash.now[:login_warning] = t('admin.user_auto_paused_message', :click_here => "https://xmo.optimix.asia/#{I18n.locale}/admin/forget_password?booking=1")
        else
          flash.now[:login_warning] = t('admin.user_paused_message', :click_here => "https://xmo.optimix.asia/#{I18n.locale}/admin/forget_password?booking=1")
        end
      end
      return render :layout => false
    end
  end

end
