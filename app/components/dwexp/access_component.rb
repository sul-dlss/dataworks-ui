module Dwexp  
  class AccessComponent < ViewComponent::Base
    def initialize(access:)
      @access = access
      super()
    end
  end
end