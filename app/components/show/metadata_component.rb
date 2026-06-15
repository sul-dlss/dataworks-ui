# frozen_string_literal: true

module Show
  # Composer for the record (show) page main content. This is the single place
  # where per-section components are added as the show page is redesigned.
  # Fields configured in CatalogController's `add_show_field` calls are rendered
  # by Show::ConfiguredFieldsComponent.
  class MetadataComponent < ViewComponent::Base
    def initialize(presenter:)
      @presenter = presenter
      super()
    end

    private

    attr_reader :presenter

    # Section components render from the SolrDocument (the data), not the
    # presenter. Only the (Show::ConfiguredFieldsComponent) needs the
    # presenter, for `field_presenters`. When/if the Show::ConfiguredFieldsComponent
    #  is removed, this component can take `document:` directly and drop the presenter.
    def document
      presenter.document
    end
  end
end
