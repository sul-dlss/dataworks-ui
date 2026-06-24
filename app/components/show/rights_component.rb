# frozen_string_literal: true

module Show
  class RightsComponent < ViewComponent::Base
    def initialize(document:)
      @rights_list = JSON.parse(document['rights_list_struct_ss'] || '[]')
      super()
    end

    # Single right display
    def display_rights_item(rights_item:)
      return '' unless rights_item['rights_uri'].present? ||
                       rights_item['rights_identifier'].present? ||
                       rights_item['rights'].present?

      # Rights text can be the name of a license or an actual piece of text defining rights
      rights_text = rights_item['rights']
      uri = rights_item['rights_uri']
      id = rights_item['rights_identifier']

      display = ''
      # If URI is present, id can be linked
      if id.present? && uri.present?
        display = "<a target='_blank' href='#{uri}'>#{id}</a>"
      # If only URI or only rights_text or id are present, display in some preference order
      else
        info_list = []
        info_list << rights_text if rights_text.present?
        info_list << id if id.present?
        info_list << "<a target='_blank' href='#{uri}'>#{uri}</a>" if uri.present?
        display = info_list.join('<br/>')
      end

      display
    end

    def display_rights
      @rights_list.map { |rights_item| display_rights_item(rights_item:) }.join('<br/>')
    end

    def render?
      @rights_list.present?
    end
  end
end
