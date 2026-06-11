# frozen_string_literal: true

module Documents
  class IndexAccessComponent < ViewComponent::Base
    def initialize(document:)
      @document = document
      super()
    end

    delegate :url, to: :@document

    def render?
      url.present?
    end

    def url_host
      URI.parse(url).host
    rescue URI::InvalidURIError
      url
    end
  end
end
