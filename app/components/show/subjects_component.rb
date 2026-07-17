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
      path_params = helpers.search_state.filter(FACET_FIELD).add(subject).to_h
      path_params[:search_field] = 'all_fields' if path_params[:search_field].blank?
      helpers.search_action_path(path_params)
    end
  end
end
