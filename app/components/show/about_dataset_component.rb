# frozen_string_literal: true

module Show
  # Renders the "About this dataset" section of the show page.
  class AboutDatasetComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    attr_reader :document
  end
end
