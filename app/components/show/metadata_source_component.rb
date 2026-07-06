# frozen_string_literal: true

module Show
  class MetadataSourceComponent < ViewComponent::Base
    def initialize(document:)
      super()
      @providers = document.struct_field('provider_identifier_map_struct_ss')
      @url = document['url_ss']
    end

    def render?
      metadata_sources.present?
    end

    # [label, url] pairs for each provider that is a source of this dataset's metadata
    def metadata_sources
      @metadata_sources ||= @providers.filter_map do |provider, id|
        source_url = provider_url(provider: provider.downcase, id: id)
        # Don't display if no URL mapped for provider OR this is already the landing page URL
        next if source_url.blank? || remove_prefix(url: @url) == remove_prefix(url: source_url)

        [I18n.t("provider.#{provider.downcase}"), source_url]
      end
    end

    def remove_prefix(url:)
      url&.sub(%r{^https?://}, '')
    end

    def provider_url(provider:, id:)
      # Redivis requires different information to be present
      # since it uses an internal id
      case provider
      when 'dryad'
        "https://datadryad.org/dataset/#{id}"
      when 'datacite'
        "https://commons.datacite.org/doi.org/#{id}"
      when 'zenodo'
        "https://zenodo.org/records/#{id}"
      when 'searchworks'
        "https://searchworks.stanford.edu/view/#{id}"
      end
    end
  end
end
