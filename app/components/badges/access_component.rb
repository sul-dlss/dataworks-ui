# frozen_string_literal: true

module Badges
  class AccessComponent < ViewComponent::Base
    attr_reader :document

    def initialize(document:)
      @document = document
      super()
    end

    def render?
      document.access.present?
    end

    def access_message
      t("badges.access.#{document.access.downcase}")
    end

    def icon_component
      case document.access.downcase
      when 'public'
        Icons::LockOpenComponent.new
      when 'restricted'
        Icons::LockClosedComponent.new
      end
    end
  end
end
