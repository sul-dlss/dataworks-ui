# frozen_string_literal: true

module Dwexp
  class StanfordDatasetFacetComponent < ViewComponent::Base
    FACET_FIELD = 'stanford_contributor_bsi'

    def initialize(response:, blacklight_config:)
      @facet_config = blacklight_config.facet_fields[FACET_FIELD]
      @facet_display = response&.aggregations&.fetch(@facet_config.field, nil) if @facet_config
      super()
    end

    def render?
      @facet_config.present? && @facet_display&.items.present?
    end

    private

    def facet_field
      @facet_field ||= helpers.facet_field_presenter(@facet_config, @facet_display)
    end

    # We only care about the first item since this facet only has one value
    def presenter
      Blacklight::FacetItemPresenter.new(
        facet_field.paginator.items.first,
        facet_field.facet_field,
        helpers,
        facet_field.key,
        facet_field.search_state
      )
    end
  end
end
