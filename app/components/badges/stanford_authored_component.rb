# frozen_string_literal: true

module Badges
  class StanfordAuthoredComponent < ViewComponent::Base
    # Solr field backing the "Stanford-authored" facet.
    FACET_FIELD = 'stanford_contributor_bsi'
    # Boolean facet, so there is a single meaningful value to filter on. Kept as
    # a string because facet values arrive from request params as strings, and
    # selected-state detection compares against those.
    FACET_VALUE = 'true'

    attr_reader :document

    def initialize(document:)
      @document = document
      super()
    end

    def render?
      document.stanford_authored?
    end

    # True when the Stanford-authored facet is already an active filter.
    def selected?
      helpers.search_state.filter(FACET_FIELD).include?(FACET_VALUE)
    end

    # Badge label, prefixed with a check icon when the facet is active.
    def label
      text = t('badges.stanford_authored')
      return text unless selected?

      safe_join([render(Icons::CheckComponent.new(classes: 'me-1', aria_hidden: true)), text])
    end

    # Blacklight facet search link. Toggles the filter: removes it when already
    # selected, otherwise adds it.
    def facet_path
      filter = helpers.search_state.filter(FACET_FIELD)
      state = selected? ? filter.remove(FACET_VALUE) : filter.add(FACET_VALUE)
      helpers.search_action_path(with_search_field(state.params))
    end

    def with_search_field(params)
      return params if params[:search_field].present?

      params.merge(search_field: helpers.blacklight_config.default_search_field&.key)
    end
  end
end
