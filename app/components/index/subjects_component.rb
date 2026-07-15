# frozen_string_literal: true

module Index
  class SubjectsComponent < ViewComponent::Base
    # Solr field backing the subjects facet.
    FACET_FIELD = 'subjects_ssim'

    def initialize(document:)
      @document = document
      super()
    end

    delegate :subjects, to: :@document

    def render?
      subjects.any?
    end

    # True when the subject is already an active facet filter on the current query.
    def subject_selected?(subject)
      helpers.search_state.filter(FACET_FIELD).include?(subject)
    end

    # Blacklight facet search link for a single subject value. Toggles the filter:
    # removes it when already selected, otherwise adds it.
    def subject_facet_path(subject)
      filter = helpers.search_state.filter(FACET_FIELD)
      state = subject_selected?(subject) ? filter.remove(subject) : filter.add(subject)
      path_params = state.to_h
      path_params[:search_field] = 'all_fields' if path_params[:search_field].blank?
      helpers.search_action_path(path_params)
    end
  end
end
