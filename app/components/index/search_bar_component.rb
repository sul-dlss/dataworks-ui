# frozen_string_literal: true

module Index
  class SearchBarComponent < Blacklight::SearchBarComponent
    DEFAULT_SEARCH_CLASSES = %w[search-card d-flex position-relative flex-column pe-4 py-1 rounded].freeze

    def initialize(search_classes: DEFAULT_SEARCH_CLASSES, **kwargs)
      @search_classes = search_classes
      super(**kwargs.reverse_merge(classes: %w[search-query-form col-md-12 col-lg-8]))
    end

    attr_reader :search_classes
  end
end
