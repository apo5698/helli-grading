class UserMailer < ApplicationMailer
  def email_on_temporary_password
    @user = params[:user]
    @random_password = params[:random_password]
    mail(to: @user.email, subject: '[AGS] Your Temporary Password')
  end
end
