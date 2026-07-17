# frozen_string_literal: true

module Index
  # Index-view presenter that renders the title from an HTML Solr field.
  class DocumentPresenter < Blacklight::IndexPresenter
    include HtmlTitle
  end
end
