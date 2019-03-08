class API::RegistrationsController < Devise::RegistrationsController
  include LocalesHelper
  before_action :configure_permitted_parameters
  before_action :permission_check, only: :create

  def create
    @verified_email = email_is_verified?

    self.resource = user_from_membership || user_from_login_token || user_from_pending_identity || build_resource
    resource.attributes=(sign_up_params)
 
    if UserService.create(user: resource)
      save_detected_locale(resource)
      if @verified_email
        sign_in resource
        flash[:notice] = t(:'devise.sessions.signed_in')
        render json: { success: :ok, signed_in: true }
      else
        LoginTokenService.create(actor: resource, uri: URI::parse(request.referrer.to_s))
        render json: { success: :ok }
      end
    else
      render json: { errors: resource.errors }, status: 422
    end
  end

  private
  def user_from_membership
    pending_membership.present? && pending_membership.user
  end

  def user_from_login_token
    pending_login_token.present? && pending_login_token.user
  end

  def user_from_pending_identity
    pending_identity.present? && pending_identity.user
  end

  def permission_check
    AppConfig.app_features[:create_user] || pending_membership
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) do |u|
      u.permit(:name, :email, :recaptcha, :legal_accepted)
    end
  end

  def email_is_verified?
    (pending_identity.present? && pending_identity.email == params[:user][:email]) or
    (pending_membership.present? && pending_membership.user.email == params[:user][:email])
  end
end
