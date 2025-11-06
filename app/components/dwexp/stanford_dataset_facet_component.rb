module Dwexp
  class StanfordDatasetFacetComponent < Blacklight::FacetFieldComponent
    # We only care about the first item since this facet only has one value
    def presenter
      Blacklight::FacetItemPresenter.new(
        @facet_field.paginator.items.first,
        @facet_field.facet_field,
        helpers,
        @facet_field.key,
        @facet_field.search_state
      )
    end
  end
end
