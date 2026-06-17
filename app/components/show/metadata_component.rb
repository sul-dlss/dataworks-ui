# frozen_string_literal: true

module Show
  # Composer for the record (show) page main content. This is the single place
  # where per-section components are added.
  # Fields configured in CatalogController's `add_show_field` calls are rendered
  # by Show::BibliographicInfoComponent.
  class MetadataComponent < ViewComponent::Base
    def initialize(presenter:)
      @presenter = presenter
      super()
    end

    private

    attr_reader :presenter

    # Section components render from the SolrDocument (the data), not the
    # presenter. Only the (Show::BibliographicInfoComponent) needs the
    # presenter, for `field_presenters`.
    def document
      presenter.document
    end
  end
end
