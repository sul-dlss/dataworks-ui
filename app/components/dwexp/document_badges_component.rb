module Dwexp
  class DocumentBadgesComponent < ViewComponent::Base
    attr_reader :document

    def initialize(document:)
      @document = document
    end

    def render?
      document.stanford_project? || document.stanford_authored?
    end
  end
end
