# frozen_string_literal: true

module Show
  # Renders the "Contributors" section of the show page: a two-column table
  # pairing each creator or contributor with their affiliation(s).
  class ContributorsComponent < ViewComponent::Base
    include AffiliationPresentation

    # Solr field backing the contributors facet, used for the search links.
    FACET_FIELD = 'contributors_ssim'

    # Number of contributors shown before the table collapses behind a toggle.
    VISIBLE_COUNT = 6

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
      @contributors ||= document.contributors
    end

    # Render a contributor's affiliation(s) for the table's second column.
    def render_affiliations(contributor)
      affiliations = Array(contributor['affiliation'])
      return if affiliations.blank?

      safe_join(affiliations.map { |affiliation| render_affiliation(affiliation) })
    end

    # Render a single affiliation: its name, ROR link, and country, if present.
    def render_affiliation(affiliation)
      parts = [affiliation['name'], render_ror_link(affiliation)]
      if (country = affiliation_country(affiliation))
        parts << tag.span(class: 'text-nowrap ms-3') do
          render(Icons::GeoAltComponent.new(classes: 'me-1', aria_hidden: true)) + country
        end
      end
      tag.div(safe_join(parts.compact), class: 'mb-1')
    end

    # Render a contributor's name as a link that opens its detail modal.
    def render_name(contributor)
      link_to(contributor['name'],
              contributor_catalog_path(id: document.id, f: { FACET_FIELD => [contributor['name']] }),
              data: { blacklight_modal: 'trigger', turbo: false })
    end

    # Render a link to the contributor's ORCID profile, if present.
    def render_orcid_link(contributor)
      url = orcid_url(contributor)
      return if url.blank?

      link_to(url, target: :blank) do
        tag.span(t('.orcid_aria_label', name: contributor['name']), class: 'visually-hidden') +
          render(Icons::OrcidComponent.new(classes: 'ms-2', aria_hidden: true))
      end
    end

    # Render the contributor's Stanford profile link with a badge, if present.
    def render_profile_link(contributor)
      id = cap_id(contributor)
      return if id.blank?

      link_to("https://profiles.stanford.edu/intranet/#{id}", class: 'profile', target: :blank) do
        tag.span(t('.stanford_profile_aria_label', name: contributor['name']), class: 'visually-hidden') +
          render(Icons::PersonFillComponent.new(classes: 'ms-1 profile', aria_hidden: true)) +
          tag.span(t('.stanford_profile'), class: 'profile', aria_hidden: true)
      end
    end

    # The ORCID profile URL for a contributor, if present.
    def orcid_url(contributor)
      value = Array(contributor['name_identifiers']).find do |id|
        id['name_identifier_scheme'] == 'ORCID'
      end&.dig('name_identifier')
      return if value.blank?
      return value if value.start_with?('http')

      "https://orcid.org/#{value}"
    end

    # The Stanford Profiles (CAP) identifier for a contributor, if present.
    def cap_id(contributor)
      Array(contributor['name_identifiers']).find do |id|
        id['name_identifier_scheme'] == 'CAP'
      end&.dig('name_identifier')
    end
  end
end
