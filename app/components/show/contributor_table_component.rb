# frozen_string_literal: true

module Show
  # Renders the "Contributors" section of the show page: a table of creators
  # and other contributors with their collaborators and affiliations.
  class ContributorTableComponent < ViewComponent::Base
    # Solr field backing the contributors facet, used for the search links in
    # each row.
    FACET_FIELD = 'contributors_ssim'

    def initialize(document:)
      @document = document
      super()
    end

    attr_reader :document

    def render?
      contributors.present?
    end

    # Creators and contributors, de-duplicated by name and identifiers.
    def contributors
      (creator_data + contributor_data).uniq do |contributor|
        [contributor['name'], contributor['name_identifiers']]
      end
    end

    private

    # Structured data for creators; by default they have no role, so we add "Creator"
    def creator_data
      @creator_data ||= document.struct_field('creators_struct_ss').tap do |creators|
        creators.each { |creator| creator['role'] = 'Creator' }
      end
    end

    # Structured data for contributors
    def contributor_data
      @contributor_data ||= document.struct_field('contributors_struct_ss')
    end
  end
end
