# frozen_string_literal: true

module Index
  class SubjectsComponent < ViewComponent::Base
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
