class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_locale
  skip_before_filter  :verify_authenticity_token
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :store_location
  before_action :authenticate_user?, :except => [:xmo_login,:authenticate_token,:current_user,:login,:logout,:login_authenticate,:create_order_by_business_opportunity,:client_approval_from_pms]
  skip_before_filter :authenticate_user?, :only => [:raise_not_found!,:render_ar_error, :render_error, :render_access_denied]
  before_filter :load_current_user
  include SendMenu 
  
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  def set_locale
    I18n.locale = params[:locale]  || I18n.default_locale
    I18n.locale = :en unless ["en", "zh-cn"].include?(I18n.locale.to_s)
  end

  def default_url_options(options={})
    { locale: I18n.locale }
  end

  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "您无权访问此页面。"
    redirect_to orders_path
  end

  def store_location
    # store last url - this is needed for post-login redirect to whatever the user last visited.
    session[:previous_url] = "" if request.path == logout_admins_path
    return unless request.get?
    if (request.path != auth_login_path &&
        request.path != "/auth/secret/new" &&
        request.path != "/auth/secret/edit" &&
        request.path != "/auth/logout" &&
        request.path != logout_admins_path &&
        request.path != forget_password_admins_path &&
        request.path != reset_mail_admins_path &&
        !request.xhr?) # don't store ajax calls
      session[:previous_url] = request.original_url
    end
  end

  # def authenticate_token
  ##ip = request.env['HTTP_X_FORWARDED_FOR'] || request.env['HTTP_X_REAL_IP'] || request.remote_ip
  ##(XomIp.include? ip)
  #   session[:user_id] = nil
  #   if params[:token]
  #      user = User.find_by_unlock_token(params[:token])
  #      if user
  #        user.unlock_token = nil
  #        user.save
  #        current_user = user
  #        session[:user_id] = user.id 
  #      end
  #   end
  #   if session[:user_id] && !params["xmo"] 
  #     redirect_to "/orders"
  #   else
  #     redirect_to login_admins_path
  #   end
  # end



  def authenticate_user?
    back_url = URI.escape(request.original_url, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    if session[:user_id]
      return true
    else
      if request.xhr?
        flash[:notice] = t("admin.timeout")
        flash.keep(:notice)
        render :js => "window.location = '#{auth_login_path}'"
      else
        redirect_to auth_login_path(back_url: back_url)
      end
    end
  end
  
  def after_sign_in_path_for(user)
    redirect_root_path = orders_path
    session[:previous_url] || redirect_root_path
  end
  
  def after_sign_out_path_for(user)
   new_user_session_path
  end

  AR_ERROR_CLASSES = [ActiveRecord::RecordNotFound, ActiveRecord::StatementInvalid]
  ERROR_CLASSES = [NameError, NoMethodError, RuntimeError,
                   ActionView::TemplateError,ActionController::MissingFile,
                   ActiveRecord::StaleObjectError, ActionController::RoutingError,
                   ActionController::UnknownController, AbstractController::ActionNotFound,
                   ActionController::MethodNotAllowed, ActionController::InvalidAuthenticityToken]

  ACCESS_DENIED_CLASSES = [CanCan::AccessDenied]

  if Rails.env.production?
    rescue_from *AR_ERROR_CLASSES, :with => :render_ar_error
    rescue_from *ERROR_CLASSES, :with => :render_error
    #rescue_from *ACCESS_DENIED_CLASSES, :with => :render_access_denied
  end
  
  def controller_name
    params["controller"]
  end
  
  def action_name
    params[:action]
  end
  
  #called by last route matching unmatched routes.  Raises RoutingError which will be rescued from in the same way as other exceptions.
  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end

  def render_ar_error(exception)
    case exception
    when *AR_ERROR_CLASSES then exception_class = exception.class.to_s
    else exception_class = 'Exception'
    end

    send_error_email(exception, exception_class)
  end

  def render_error(exception)
    case exception
    when *ERROR_CLASSES then exception_class = exception.class.to_s
    else exception_class = 'Exception'
    end

    send_error_email(exception, exception_class)
  end

  def render_access_denied(exception)
    case exception
    when *ACCESS_DENIED_CLASSES then exception_class = exception.class.to_s
    else exception_class = "Exception"
    end
    send_error_email(exception, exception_class)
  end

  def send_error_email(exception, exception_class)
    @message_log = Logger.new("log/booking_system_console_exception.log", "weekly")

    if current_user.administrator?
      if AR_ERROR_CLASSES.include?(exception.class)
        flash[:warning] = "Sorry! Error opening " + request.url + "<br/>" + exception.class.to_s
      else
        flash[:warning] = "Sorry! Error opening " + request.url + "<br/>" + exception.message
      end
    else
      flash[:warning] = "Sorry! Error opening " + request.url
    end

    if SEND_EMAIL == true and RECIPIENTS.to_s.strip != ""
      msg = "type      : #{exception_class}\n"
      msg += "url      : #{request.url}\n"
      msg += "----------------------------------------------"
      msg += "request  : #{request.inspect}\n"
      msg += "----------------------------------------------"
      msg += "message   : #{exception.message}\n"
      msg += "backtrace : #{exception.backtrace[0..10].join("\n")}"
      begin
        ErrorWorker.perform_async(RECIPIENTS,msg)
      rescue
      end
    end
    @message_log.debug "#{Time.now.strftime("%Y-%m-%d %H:%M:%S")}|#{exception_class}|#{exception.message}|#{exception.backtrace[0]}"

    return redirect_to :controller => :admins, :action =>:error_mail
  end


  def load_current_user
    Order.update_user = current_user rescue nil
  end

  def api_authenticate
    authenticate_or_request_with_http_token do |token, options|
      token == "c576f0136149a2e2d9127b3901019855"
    end
  end

  protected

  def configure_permitted_parameters
   devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:username, :email, :password) }
  end
  
end
