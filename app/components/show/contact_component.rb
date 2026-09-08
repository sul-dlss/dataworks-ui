# frozen_string_literal: true

module Show
  class ContactComponent < ViewComponent::Base
    attr_reader :access_contacts

    def initialize(document:)
      @access_contacts = document.access_contact_struct
      super()
    end

    def render?
      access_contacts.present?
    end
  end
end
