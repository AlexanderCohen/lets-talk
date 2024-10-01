require "test_helper"

# rails test test/controllers/users_controller_test.rb
class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(email: "test123@example.com", password: "password", first_name: "Test", last_name: "User")
    # @user.create_default_account
  end

  class JoinCodesTest < UsersControllerTest
    test "can invite users via join codes" do
      get "http://www.example.com/join/#{@user.current_account.join_code}"
      assert_response :success
    end
  end
end
