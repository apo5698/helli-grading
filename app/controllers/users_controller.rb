class UsersController < ApplicationController
  before_action :catch_denied_access, except: %i[new create]

  def new
    flash.alert = 'Helli has closed public registration.'
    redirect_back(fallback_location: '')
    # render layout: 'pre_application'
  end

  def create
    user = User.create(user_params.merge(password_params))
    messages = user.errors.full_messages
    if messages.blank?
      session[:user_id] = user.id
      flash.notice = 'You have successfully signed in.'
      redirect_to '/'
    else
      flash_errors(messages)
      redirect_to '/users/new'
    end
  end

  def show
    @user = User.find(params[:id])
  end

  def update
    user = User.find(params[:id])
    user.update_attributes(user_params)
    unless params[:user][:password].blank?
      user.update_attributes(password_params)
    end

    messages = user.errors.full_messages << user.update_avatar(params[:user][:avatar])
    if messages.blank?
      flash.notice = 'Your profile has been updated.'
    else
      flash_errors(messages)
    end
    redirect_to '/'
  end

  def destroy
    user = User.find(params[:id])
    if user.authenticate(params[:password_confirmation])
      user.destroy
      session[:user_id] = nil
      flash.notice = 'You account has been deleted.'
      redirect_to root_path
    else
      flash[:modal_error] = 'The password you entered does not match our record. Please try again.'
    end
    redirect_to '/'
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
