module Dwexp
  class CollaboratorsModalComponent < Blacklight::System::ModalComponent
    def initialize(contributors:, facet:)
      super()
      @contributors = contributors
      @facet = facet
      @items = facet.display_facet.items
    end

    def datasets_count
      @items.filter_map { |item| item.hits if @contributors.include? item.value }.sum
    end

    def collaborators
      @items.reject { |item| @contributors.include? item.value }.map do |item|
        Blacklight::FacetItemPresenter.new(
          item,
          @facet.facet_field,
          @facet.view_context,
          @facet.key,
          @facet.search_state
        )
      end
    end
  end
end
