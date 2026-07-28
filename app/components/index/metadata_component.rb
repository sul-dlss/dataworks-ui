# frozen_string_literal: true

module Index
  class MetadataComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    delegate :publication_year, :embargoed?, to: :@document
  end
end
