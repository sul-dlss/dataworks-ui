# frozen_string_literal: true

module Show
  class RightsComponent < ViewComponent::Base
    def initialize(document:)
      @rights_list = document.struct_field('rights_list_struct_ss')
      super()
    end

    def render?
      @rights_list.present?
    end

    # Each rights entry as a list of [text, href] fragments shown on its own line(s).
    # A nil href renders the text as-is; otherwise the text links to the href.
    def rights_entries
      @rights_list.map { |item| item_fragments(item) }.reject(&:empty?)
    end

    def item_fragments(item)
      # Rights text can be the name of a license or actual text defining rights
      id = item['rights_identifier']
      uri = item['rights_uri']

      # When both are present, the identifier links to the URI
      return [[id, uri]] if id.present? && uri.present?

      # Otherwise show whatever is present in preference order; a bare URI links to itself
      [].tap do |fragments|
        fragments << [item['rights'], nil] if item['rights'].present?
        fragments << [id, nil] if id.present?
        fragments << [uri, uri] if uri.present?
      end
    end
  end
end
