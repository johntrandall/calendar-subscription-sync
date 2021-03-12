# app/controllers/users/omniauth_callbacks_controllers.rb
class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def google_oauth2
    # TODO remove logging here - security issue
    Rails.logger.info { "*************** google_oauth2 Callback" }
    Rails.logger.info { "request.env['omniauth.auth']: #{request.env["omniauth.auth"]}" }

    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      sign_in @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Google") if is_navigational_format?
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
    end
    redirect_to '/'
  end

end
