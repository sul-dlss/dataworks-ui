module Dwexp  
  class RightsComponent < ViewComponent::Base
    def initialize(rights_list)
      @rights_list = JSON.parse(rights_list || '[]')
      super()
    end

    # Single right display
    def display_rights_item(rights_item)
      return '' unless rights_item['rights_uri'].present? ||
                       rights_item['rights_identifier'].present? ||
                       rights_item['rights'].present?
      info_list = []
      info_list << rights_item['rights'] if rights_item['rights'].present?
      info_list << rights_item['rights_identifier'] if rights_item['rights_identifier'].present?
      info_list << rights_item['rights_uri'] if rights_item['rights_uri'].present?

      info_list.join(',')
    end

    def display_rights
      sanitize @rights_list.map { |rights_item| display_rights_item(rights_item) }.join('<br/>')
    end

    def render?
      @rights_list.length > 0
    end
  end
end