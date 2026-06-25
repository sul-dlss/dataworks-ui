# frozen_string_literal: true

module Show
  class ContributorModalComponent < Blacklight::System::ModalComponent
    include AffiliationPresentation

    def initialize(contributors:, facet:, affiliations: [])
      super()
      @contributors = contributors
      @facet = facet
      @affiliations = affiliations
      @items = facet.display_facet.items
    end

    def datasets_count
      @items.filter_map { |item| item.hits if @contributors.include? item.value }.sum
    end

    # The departments listed for an affiliation, excluding repeats of the affiliation name.
    def departments(affiliation)
      Array(affiliation['affiliation_department_name']).reject { |dept| affiliation['name'].include?(dept) }
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
