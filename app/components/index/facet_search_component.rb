# frozen_string_literal: true

module Index
  # Sidebar facet renderer that adds a SearchWorks-style facet search box below
  # the "Browse all" link. The box (and link) only appear when the facet has a
  # modal_path — i.e. when there are more values than the display limit.
  class FacetSearchComponent < Blacklight::Facets::ListComponent
    # A presenter with modal_path suppressed, so the layout (FieldComponent)
    # doesn't render its own "Browse all" link — we place it ourselves alongside
    # the search box.
    class FacetPresenterWithoutModal < SimpleDelegator
      def modal_path; end
    end

    def facet_field_without_more_link
      FacetPresenterWithoutModal.new(@facet_field)
    end
  end
end
