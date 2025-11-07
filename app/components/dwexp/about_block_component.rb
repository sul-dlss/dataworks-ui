module Dwexp  
  class AboutBlockComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end
  end
end