# frozen_string_literal: true

module Dwexp
  class DocumentTitleComponent < Blacklight::DocumentTitleComponent
    # Callers can opt out of the access badge via `access_badge: false`. The show
    # page does so because it renders the badge itself in
    # Show::AboutDatasetComponent; the results list uses the default (true).
    def initialize(*, access_badge: true, **)
      @access_badge = access_badge
      super(*, **)
    end

    def render_access_badge?
      @access_badge
    end
  end
end
