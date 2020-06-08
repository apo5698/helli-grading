class UsersController < ApplicationController
  def new
    render layout: 'pre_application'
  end

  def create
    user = User.create(user_params.merge(password_params))
    if user.errors.full_messages.blank?
      session[:user] = user
    else
      flash[:error] = user.errors.full_messages
    end
    redirect_to root_path
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

  def upload_file

  end
end
