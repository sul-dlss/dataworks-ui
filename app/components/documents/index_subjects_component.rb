# frozen_string_literal: true

module Documents
  class IndexSubjectsComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    delegate :subjects, to: :@document

    def render?
      subjects.any?
    end
  end
end
