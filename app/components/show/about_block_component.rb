# frozen_string_literal: true

module Show
  class AboutBlockComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end
  end
end
