class Users::PasswordsController < Devise::PasswordsController
  layout false
  skip_before_filter :require_no_authentication, :only => [:edit, :update]
  # skip_before_filter :assert_reset_token_passed, :only => :edit
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  def edit
    super
  end

  # PUT /resource/password
  def update
    # super
    self.resource = resource_class.reset_password_by_token(resource_params)
    yield resource if block_given?
    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      resource.user_state='active'
      resource.is_active=true
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message) if is_flashing_format?
      sign_in(resource_name, resource)
      respond_with resource, location: after_resetting_password_path_for(resource)
    else
      respond_with resource
    end

  end


  protected

  def require_no_authentication
    if current_user.administrator?
      return true
    else
      return super
    end
  end

  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      set_flash_message(:error, :no_token)
      redirect_to new_session_path(resource_name)
    end

  end

  protected

  def after_resetting_password_path_for(resource)
    super(resource)
  end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
