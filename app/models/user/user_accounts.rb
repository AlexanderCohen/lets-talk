module User::UserAccounts
  extend ActiveSupport::Concern

  included do
    has_many :account_users, dependent: :destroy

    has_many :accounts, through: :account_users
    has_many :owned_accounts, foreign_key: :owner_id, class_name: "Account"

    after_create :create_default_account
  end

  def create_default_account
    return accounts.first if accounts.any?

    account = owned_accounts.new(name: name)
    account.account_users.new(user: self, account_admin: true)
    account.save!
    account
  end
end
