# frozen_string_literal: true

module Show
  # Renders the record (show) page fields that are still
  # configured via CatalogController's `add_show_field`, using
  # Blacklight's default metadata rendering. This preserves the current output
  # while sections are migrated to dedicated Show::* components one at a time.
  #
  # Once all fields are migrated, this component can be deleted.
  class ConfiguredFieldsComponent < ViewComponent::Base
    def initialize(presenter:)
      @presenter = presenter
      super()
    end

    def call
      render @presenter.view_config.document_metadata_component.new(fields: @presenter.field_presenters)
    end
  end
end
