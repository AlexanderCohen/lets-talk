module User::Auth
  extend ActiveSupport::Concern

  # We want to add Omniauthable at some point in the future.
  # We should also setup confirmable and lockable etc to try lock out malicious users.

  included do
    # Others available are: :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable
  end
end
