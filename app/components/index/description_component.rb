# frozen_string_literal: true

module Index
  class DescriptionComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    def render?
      @document.description_html.present?
    end

    def description
      helpers.render_rich_text(value: Array(@document.description_html))
    end
  end
end
