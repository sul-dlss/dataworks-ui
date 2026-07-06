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

    # Blacklight facet search link for a single subject value.
    def subject_facet_path(subject)
      helpers.search_action_path(helpers.search_state.filter(FACET_FIELD).add(subject))
    end
  end
end
