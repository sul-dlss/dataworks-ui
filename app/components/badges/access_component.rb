# frozen_string_literal: true

module Badges
  class AccessComponent < ViewComponent::Base
    # Solr field backing the access facet.
    FACET_FIELD = 'access_ssi'

    attr_reader :document

    def initialize(document:)
      @document = document
      super()
    end

    def render?
      document.access.present?
    end

    def access_message
      t("badges.access.#{document.access.downcase}")
    end

    # The facet value is the raw, case-preserved Solr value (e.g. "Public").
    def facet_value
      document.access
    end

    # True when this access value is already an active filter.
    def selected?
      helpers.search_state.filter(FACET_FIELD).include?(facet_value)
    end

    # Blacklight facet search link. Toggles the filter: removes it when already
    # selected, otherwise adds it.
    def facet_path
      filter = helpers.search_state.filter(FACET_FIELD)
      state = selected? ? filter.remove(facet_value) : filter.add(facet_value)
      helpers.search_action_path(with_search_field(state.params))
    end

    def with_search_field(params)
      return params if params[:search_field].present?

      params.merge(search_field: helpers.blacklight_config.default_search_field&.key)
    end

    # A check icon when the facet is active, otherwise the lock reflecting the
    # access level.
    def icon_component
      return Icons::CheckComponent.new(aria_hidden: true) if selected?

      case document.access.downcase
      when 'public'
        Icons::LockOpenComponent.new(aria_hidden: true)
      when 'restricted'
        Icons::LockClosedComponent.new(aria_hidden: true)
      end
    end
  end
end
