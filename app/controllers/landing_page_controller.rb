# frozen_string_literal: true

class LandingPageController < ApplicationController
  include Blacklight::Configurable

  configure_blacklight do |config|
    config.header_component = LandingPage::HeaderComponent
    config.full_width_layout = true
    config.logo_link = 'https://library.stanford.edu'
    config.autocomplete_enabled = false
    config.advanced_search.enabled = false

    config.add_search_field 'all_fields', label: 'All Fields'
    config.add_search_field 'title', label: 'Title'
    config.add_search_field 'author', label: 'Author'
    config.add_search_field 'subject', label: 'Subject'
    config.add_search_field 'doi', label: 'DOI'
  end

  def index
    @popular_subjects = Rails.cache.fetch('landing_page/popular_subjects', expires_in: 1.hour) do
      solr = RSolr.connect url: Blacklight.connection_config[:url]
      response = solr.get 'select', params: {
        'q' => '*:*',
        'rows' => 0,
        'facet' => 'true',
        'facet.field' => 'subjects_ssim',
        'facet.limit' => 30,
        'facet.sort' => 'count'
      }
      flat = response.dig('facet_counts', 'facet_fields', 'subjects_ssim') || []
      flat.each_slice(2).map(&:first)
    rescue RSolr::Error::Http, Errno::ECONNREFUSED, Net::OpenTimeout, Net::ReadTimeout => e
      Rails.logger.error("#{self.class}: failed to fetch popular subjects (#{e.class}): #{e.message}")
      []
    end
  end
end
