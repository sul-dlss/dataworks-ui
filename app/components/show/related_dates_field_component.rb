# frozen_string_literal: true

module Show
  # Renders the "Related dates" show field within the bibliographic info
  # definition list.
  class RelatedDatesFieldComponent < Blacklight::MetadataFieldComponent
    # Dates without a date_type are omitted.
    def render_field_values
      @field.document.dates_struct.filter_map do |val|
        "#{val['date_type']}: #{val['date']}" if val['date_type'].present?
      end
    end
  end
end
