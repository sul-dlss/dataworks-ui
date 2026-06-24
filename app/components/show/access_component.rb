# frozen_string_literal: true

module Show
  class AccessComponent < ViewComponent::Base
    def initialize(document:)
      @access = document['access_ssi']
      super()
    end
  end
end
