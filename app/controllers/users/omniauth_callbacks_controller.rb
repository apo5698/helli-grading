# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: User.providers.keys

  User.providers.each_key do |provider|
    define_method provider do
      authenticate(provider)
    end
  end

  protected

  def authenticate(provider)
    provider = provider.to_sym
    auth = request.env['omniauth.auth']
    user = User.from_omniauth(auth, provider)
    sign_in_and_redirect user, event: :authentication
    set_flash_message(:notice, :success, kind: User.providers[provider]) if is_navigational_format?
  rescue Helli::OAuthUserExists
    @provider = User.providers[provider]
    render 'errors/422', layout: 'pre_application', status: :unprocessable_entity
  end

  # More info at:
  # https://github.com/heartcombo/devise#omniauth

  # GET|POST /resource/auth/twitter
  # def passthru
  #   super
  # end

  # GET|POST /users/auth/twitter/callback
  # def failure
  #   super
  # end

  # protected

  # The path used when OmniAuth fails
  # def after_omniauth_failure_path_for(scope)
  #   super(scope)
  # end
end
