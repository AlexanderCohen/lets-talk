module User::Accessibility
  extend ActiveSupport::Concern

  included do
    after_initialize :set_default_text_size_modifier, if: :new_record?
  end

  def set_default_text_size_modifier
    self.text_size_modifier ||= 1
  end
end
