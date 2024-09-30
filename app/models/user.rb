class User < ApplicationRecord
  include User::UserConfig

  has_many :phrases, dependent: :destroy
end
