# frozen_string_literal: true

module Show
  # Renders the "Subjects" section of the show page.
  class SubjectsComponent < ViewComponent::Base
    # Solr field backing the subjects facet.
    FACET_FIELD = 'subjects_ssim'

    def initialize(document:)
      @document = document
      super()
    end

    attr_reader :document

    def render?
      document.subjects.present?
    end

    # Blacklight facet search link for a single subject value.
    def subject_facet_path(subject)
      helpers.search_action_path(helpers.search_state.filter(FACET_FIELD).add(subject))
    end
  end
end
