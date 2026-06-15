# frozen_string_literal: true

module Show
  # Document component for the record (show) page. Replaces Blacklight's default
  # config-driven metadata rendering with a custom set of components
  # for rendering metadata (see Show::MetadataComponent).
  class DocumentComponent < Blacklight::DocumentComponent
  end
end
