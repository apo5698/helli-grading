class UsersController < ApplicationController
  def new
    render layout: 'pre_application'
  end

  def create
    session[:user] = User.create(user_params)
    redirect_to root_path
  end

  def show
    @user = User.find_by(id: params[:id])
  end

  def update
    user = User.find(params[:id])
    user.update_attributes(user_params)
    unless params[:user][:password].blank?
      user.update_attributes(password_params)
    end
    if user.errors.full_messages.blank?
      flash[:success] = 'Your profile has been updated.'
    else
      flash[:error] = user.errors.full_messages
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
end
