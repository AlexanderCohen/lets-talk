module User::UserAccounts
  extend ActiveSupport::Concern

  included do
    has_many :account_users, dependent: :destroy
    belongs_to :current_account, foreign_key: :current_account_id, class_name: "Account", optional: true

    has_many :accounts, through: :account_users
    has_many :owned_accounts, foreign_key: :owner_id, class_name: "Account"

    accepts_nested_attributes_for :accounts

    after_create :create_default_account
  end

  def create_default_account
    return accounts.first if accounts.any?

    account = owned_accounts.new(name: name, owner: self)
    account.account_users.new(user: self, account_admin: true)
    account.save!

    update(current_account_id: account.id)
    account
  end
end
