class Account < ApplicationRecord
  include Account::Joinable

  belongs_to :owner, class_name: "User"

  has_many :account_users, dependent: :destroy
  has_many :users, through: :account_users
end

