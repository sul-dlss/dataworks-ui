# frozen_string_literal: true

module Show
  # Show-view presenter that renders the title from an HTML Solr field.
  class DocumentPresenter < Blacklight::ShowPresenter
    include HtmlTitle
  end
end
