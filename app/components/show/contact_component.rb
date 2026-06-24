# frozen_string_literal: true

module Show
  class ContactComponent < ViewComponent::Base
    def initialize(document:)
      @contact_info = JSON.parse(document['access_contact_struct_ss'] || '[]')
      super()
    end

    def render?
      @contact_info.present?
    end

    def display_contact_item(contact_item:)
      name_display = contact_item['name'].present? ? "<h3>#{contact_item['name']}</h3>" : ''
      email_display = if contact_item['email'].present?
                        "<i class='bi bi-envelope mail me-1'></i>#{contact_item['email']}"
                      else
                        ''
                      end
      "<div class='mb-2'>#{name_display} #{email_display}</div>"
    end

    def display_contacts
      @contact_info.map { |contact_item| display_contact_item(contact_item:) }.join
    end
  end
end
