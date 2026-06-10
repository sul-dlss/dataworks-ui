# frozen_string_literal: true

module Documents
  class IndexDescriptionComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    def render?
      @document.description.present?
    end

    def description
      helpers.render_rich_text(value: Array(@document.description))
    end
  end
end
