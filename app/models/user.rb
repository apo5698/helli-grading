class User < ApplicationRecord
  # OAuth2 providers
  enum provider: {
    google_oauth2: 'Google',
    github: 'GitHub'
  }

  # Devise's models
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable, :lockable, :timeoutable, :trackable,
         :omniauthable, omniauth_providers: providers.keys

  # Relations
  has_many :courses, dependent: :destroy
  has_many :assignments, through: :courses

  # Validations
  validates :name, presence: true
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :password_confirmation, presence: true

  # User's role
  enum role: {
    admin: 'Admin',
    instructor: 'Instructor',
    ta: 'Teaching assistant',
    student: 'Student'
  }

  # Finds a current or creates a new user from omniauth.
  #
  # @param [Hash] auth see <a href="https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema">Auth Hash Schema</a>
  # @param [Symbol] provider OAuth2 provider
  # @return [User] user
  def self.from_omniauth(auth, provider)
    raise "Unknown OAuth provider #{provider}" unless providers.key?(provider)

    user = find_or_initialize_by(provider: auth.provider, uid: auth.uid)
    return user if user.persisted?

    user.name = auth.info.name
    user.email = auth.info.email
    user.username = auth.info.nickname || auth.info.email

    random_password = Devise.friendly_token
    user.password = random_password
    user.password_confirmation = random_password
    user.random_password = true

    user.skip_confirmation!

    raise Helli::OAuthUserExists if user.invalid?

    user.save
    user
  end

  # Returns user's name.
  #
  # @return [String] name
  def to_s
    name
  end
end
