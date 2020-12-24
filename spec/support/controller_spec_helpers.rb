module ControllerSpecHelpers
  def login_as(email)
    name = email.split('@')[0]
    u = user(name, email, '123456')
    request.session[:user_id] = u.id
  end

  def logout
    session[:user_id] = nil
  end

  def user(name, email, password)
    u = User.find_by(email: email)
    return u if u.present?

    u = User.create(
      name: name,
      email: email,
      password: password,
      password_confirmation: password
    )
    raise ActiveRecord::RecordInvalid, u if u.invalid?

    u
  end

  def login_as_admin
    login_as 'admin@helli.app'
  end

  def login_as_ta
    login_as 'ta@ncsu.edu'
  end

  def current_user
    User.find!(request.session[:user_id])
  end
end
