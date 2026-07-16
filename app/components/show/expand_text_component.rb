# frozen_string_literal: true

module Show
  # Wraps arbitrary content in the "Show more"/"Show less" truncation UI.
  #
  # The content is clamped to lines and the toggle is revealed by the
  # expand-text Stimulus controller only when the content actually overflows.
  class ExpandTextComponent < ViewComponent::Base
    def initialize(lines: 5)
      @lines = lines
      super()
    end

    attr_reader :lines
  end
end
