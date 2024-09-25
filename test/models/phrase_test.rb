require "test_helper"

class PhraseTest < ActiveSupport::TestCase
  def setup
    @user = users(:one)
    @phrase = @user.phrases.build(text: "Hello, world!", category: "Greetings", audio_url: "http://example.com/audio.mp3")
  end

  test "should be valid" do
    assert @phrase.valid?
  end

  test "user_id should be present" do
    @phrase.user_id = nil
    assert_not @phrase.valid?
  end

  test "text should be present" do
    @phrase.text = ""
    assert_not @phrase.valid?
  end

  test "category should be present" do
    @phrase.category = ""
    assert_not @phrase.valid?
  end
end
