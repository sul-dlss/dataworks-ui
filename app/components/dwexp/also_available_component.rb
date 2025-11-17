module Dwexp
  class AlsoAvailableComponent < ViewComponent::Base
    def initialize(document:)
      @providers_info = document['provider_identifier_map_struct_ss']
      @url = document['url_ss']
      @available = extract_also_available
      super()
    end

    def extract_also_available
      return if @providers_info.blank?

      JSON.parse(@providers_info).map do |provider, id|
        available_url = provider_url(provider: provider.downcase, id: id)
        # Don't display if no URL mapped for provider OR this is already the landing page URL
        next if available_url.blank? || remove_prefix(url: @url) == remove_prefix(url: available_url)

        "<a target='_blank' href='#{available_url}'>#{I18n.t("provider.#{provider.downcase}")}</a>"
      end.compact.join('<br/>')
    end

    def render?
      @available.present?
    end

    def remove_prefix(url:)
      url&.sub(/^https?:\/\//, '')
    end

    def provider_url(provider:, id:)
      # Redivis requires different information to be present
      # since it uses an internal id
      case provider
      when "dryad"
        "https://datadryad.org/dataset/#{id}"
      when "datacite"
        "https://commons.datacite.org/doi.org/#{id}"
      when "zenodo"
        "https://zenodo.org/records/#{id}"
      when "searchworks"
        "https://searchworks.stanford.edu/view/#{id}"
      else
        nil
      end
    end
  end

end
