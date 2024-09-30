module AccessibilityHelper

  TEXT_SIZE_OPTIONS = [{name: "Small", value: -1}, {name: "Normal", value: 0}, {name: "Large", value: 1}].freeze
  TEXT_SIZE_STYLES = ["text-xs", "text-sm", "text-base", "text-lg", "text-xl", "text-2xl"].freeze

  def text_size_for(style)
    # Users can configure their text size modifier, by default it's 1,
    # meaning that the text size will be incremented by 1.

    index_for_style = TEXT_SIZE_STYLES.index(style) + (current_user.text_size_modifier.to_i || 1)
    # Ensure the index is within the valid range
    index_for_style = [[0, index_for_style].max, TEXT_SIZE_STYLES.length - 1].min
    TEXT_SIZE_STYLES[index_for_style]
  end

  def text_size_modifier_options
    TEXT_SIZE_OPTIONS.map { |option| [option[:name], option[:value]] }
  end
end
