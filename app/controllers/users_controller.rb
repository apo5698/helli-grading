class UsersController < ApplicationController
  before_action :catch_denied_access, except: %i[new create]

  def new
    render layout: 'pre_application'
  end

  def create
    user = User.create(user_params.merge(password_params))
    if user.errors.full_messages.blank?
      session[:user] = user
      redirect_to root_path
    else
      flash[:error] = user.errors.full_messages
      redirect_back new_user_path
    end
  end

  def show
    @user = User.find_by(id: params[:id])
  end

  def update
    user = User.find(params[:id])
    user.update_attributes(user_params)
    avatar_error_msg = user.update_avatar(params[:user][:avatar])
    unless params[:user][:password].blank?
      user.update_attributes(password_params)
    end
    if user.errors.full_messages.blank? && avatar_error_msg.blank?
      session[:user] = user
      flash[:success] = 'Your profile has been updated.'
    else
      messages = user.errors.full_messages << avatar_error_msg
      flash[:error] = messages.uniq.reject(&:blank?).join("\n")
    end

    redirect_to user_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email,
                                 :phone_number, :date_of_birth,
                                 :gender, :path_to_avatar)
  end

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def access_allowed?
    super and session[:user].id == params[:id].to_i
  end
end
