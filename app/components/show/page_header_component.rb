# frozen_string_literal: true

module Show
  # Page header for the record (show) page. Blacklight's default stacks the
  # back-to-search link above the prev/next paging controls; here we render the
  # "Search results" link and the paging controls inline on a single row that
  # centers at medium and smaller widths.
  class PageHeaderComponent < Blacklight::Document::PageHeaderComponent
  end
end
