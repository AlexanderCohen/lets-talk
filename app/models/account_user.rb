class AccountUser < ApplicationRecord
  belongs_to :account, inverse_of: :account_users
  belongs_to :user, inverse_of: :account_users

  validates :user_id, uniqueness: {scope: :account_id}

  after_initialize :set_roles, if: :new_record?

  def account_owner?
    account.owner_id == user_id
  end

  private

  def set_roles
    self.roles ||= []
  end
end
