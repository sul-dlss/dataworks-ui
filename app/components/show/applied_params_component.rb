# frozen_string_literal: true

module Show
  # Applied params display for the record (show) page. Replaces Blacklight's
  # default, which renders both a "Clear all" button and a "Back to Search"
  # button. Here we drop "Clear all" (it remains on the results view) and render
  # the back-to-search action as a "Search results" link.
  class AppliedParamsComponent < Blacklight::SearchContext::ServerAppliedParamsComponent
  end
end
