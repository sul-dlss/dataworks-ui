# frozen_string_literal: true

module Badges
  # A single subject facet pill: a Bootstrap pill badge linking to a facet search.
  # Shared by the index and show subjects components so the styling stays in one place.
  #
  # Pass selected: as true/false to render a filter toggle
  # Leave it nil for a plain navigational pill.
  class SubjectPillComponent < ViewComponent::Base
    def initialize(subject:, path:, selected: nil)
      @subject = subject
      @path = path
      @selected = selected
      super()
    end

    attr_reader :subject, :path

    # True when this pill behaves as a filter toggle rather than a plain link.
    def toggle?
      !@selected.nil?
    end

    def selected?
      @selected == true
    end

    # Pill label, prefixed with a check icon when the subject is selected.
    def label
      return subject unless selected?

      safe_join([render(Icons::CheckComponent.new(classes: 'me-1', aria_hidden: true)), subject])
    end
  end
end
