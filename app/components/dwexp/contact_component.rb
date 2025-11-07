module Dwexp  
  class ContactComponent < ViewComponent::Base
    def initialize(contact_info:)
      @contact_info = JSON.parse(contact_info || '[]')
      super()
    end

    def render?
      @contact_info.present?
    end

    def display_contact_item(contact_item:)
      name_display = contact_item['name'].present? ? "<h3>#{contact_item['name']}</h3>" : ''  
      email_display = contact_item['email'].present? ? "<i class='bi bi-envelope mail me-1'></i>#{contact_item['email']}" : ''
      "<div class='mb-2'>#{name_display} #{email_display}</div>"
    end

    def display_contacts
      @contact_info.map { |contact_item| display_contact_item(contact_item:) }.join('')
    end

  end
end