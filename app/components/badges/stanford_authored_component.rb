# frozen_string_literal: true

module Badges
  class StanfordAuthoredComponent < ViewComponent::Base
    attr_reader :document

    def initialize(document:)
      @document = document
      super()
    end

    def render?
      document.stanford_authored?
    end
  end
end
