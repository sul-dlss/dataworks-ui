# frozen_string_literal: true

module Show
  # Renders the "Content/Summary" section of the show page.
  class ContentSummaryComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    attr_reader :document

    def render?
      document.description.present?
    end

    def description
      helpers.render_rich_text(value: Array(document.description))
    end
  end
end
