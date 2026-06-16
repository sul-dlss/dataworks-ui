# frozen_string_literal: true

module Show
  # Renders the "Bibliographic information" section of the show page.
  #
  # Unlike the other Show::* sections (which read from the SolrDocument and use
  # bespoke layouts), this section is a plain definition list of label/value
  # pairs, so it intentionally keeps using the fields configured via
  # CatalogController's `add_show_field` calls and Blacklight's default metadata
  # rendering.
  class BibliographicInfoComponent < ViewComponent::Base
    def initialize(presenter:)
      @presenter = presenter
      super()
    end

    attr_reader :presenter

    # Hide the section (heading included) when none of the configured fields
    # have a value.
    def render?
      field_presenters.any?
    end

    def metadata_component
      presenter.view_config.document_metadata_component.new(fields: field_presenters, show: true)
    end

    # Presenters for the configured show fields that have a value.
    def field_presenters
      @field_presenters ||= presenter.field_presenters.to_a
    end
  end
end
