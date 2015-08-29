# Users
module Users
  # OmniauthCallbacksController
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Find or create a user by google oauth credentials
    def google_oauth2
      # You need to implement the method below in your model (e.g. app/models/user.rb)
      @user = User.find_for_google_oauth2(request.env['omniauth.auth'], current_user)
      @user.update_attribute(:refresh_token, request.env['omniauth.auth'].credentials.refresh_token)
      set_notice_and_redirect
    end

    private

    def set_notice_and_redirect
      if @user.persisted?
        flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: 'Google'
        sign_in_and_redirect @user, event: :authentication
      else
        session['devise.google_data'] = request.env['omniauth.auth']
        redirect_to new_user_registration_url
      end
    end
  end
end
