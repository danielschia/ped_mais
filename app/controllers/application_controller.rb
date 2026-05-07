class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  helper_method :current_user

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email])
  end

  def require_owner!
    unless current_user&.owner?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def require_customer!
    unless current_user&.customer?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end
end
