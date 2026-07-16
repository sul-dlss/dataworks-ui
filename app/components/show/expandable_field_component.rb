# frozen_string_literal: true

module Show
  # Renders a field, wrapping its rendered value(s) in the "Show more"/
  # "Show less" truncation UI.
  class ExpandableFieldComponent < Blacklight::MetadataFieldComponent
    def render_field_values
      [render(Show::ExpandTextComponent.new) { safe_join(super, tag.br) }]
    end
  end
end
