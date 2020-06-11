class UsersController < ApplicationController
  before_action :catch_denied_access, except: %i[new create reset_password]

  def new
    render layout: 'pre_application'
  end

  def create
    user = User.create(user_params.merge(password_params))
    messages = user.errors.full_messages
    if messages.blank?
      session[:user] = user
      FileUtils.mkdir_p Rails.root.join('public', 'uploads', 'users', user.email)
      flash[:success] = 'You have successfully signed in.'
      redirect_to root_path
    else
      flash[:error] = messages.uniq.reject(&:blank?).join(".\n") << '.'
      redirect_to new_user_path
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
      flash[:error] = messages.uniq.reject(&:blank?).join(".\n") << '.'
    end

    redirect_to user_path
  end

  def destroy
    user = User.find(params[:id])
    if user.authenticate(password_params[:password])
      user.destroy
      session[:user] = nil
      flash[:success] = 'You account has been deleted.'
      redirect_to root_path
    else
      flash[:error] = 'The password you entered does not match our record. Please try again.'
      redirect_to user_path
    end
  end

  def reset_password
    user = User.find_by(email: params[:user][:recovery_email])
    if user
      random_password = user.random_password
      UserMailer.with(user: user, random_password: random_password).email_on_temporary_password.deliver_later
      flash[:success] = 'An temporary password has been sent to your email. Please check it!'
    else
      flash[:error] = 'The email you entered does not match our record. Please try another.'
    end
    redirect_to root_path
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
