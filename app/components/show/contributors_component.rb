# frozen_string_literal: true

module Show
  # Renders the "Contributors" section of the show page: a list of creators and
  # other contributors alongside a numbered list of their shared affiliations.
  class ContributorsComponent < ViewComponent::Base
    include AffiliationPresentation

    # Solr field backing the contributors facet, used for the search links.
    FACET_FIELD = 'contributors_ssim'

    # Number of contributors shown before the list collapses behind a toggle.
    VISIBLE_COUNT = 5

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

    # Every affiliation across all contributors, de-duplicated and ordered. An
    # affiliation's position is its superscript key in the affiliations block,
    # linking a contributor back to its institution(s).
    def affiliations
      @affiliations ||= contributors.flat_map { |contributor| Array(contributor['affiliation']) }
                                    .uniq { |affiliation| affiliation_key(affiliation) }
    end

    # The superscript number(s) linking a contributor to its affiliation(s).
    def affiliation_numbers(contributor)
      Array(contributor['affiliation']).filter_map { |affiliation| affiliation_number(affiliation) }.uniq.sort
    end

    # 1-based position of an affiliation within #affiliations.
    def affiliation_number(affiliation)
      index = affiliations.index { |candidate| affiliation_key(candidate) == affiliation_key(affiliation) }
      index && (index + 1)
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

    # Render the superscript reference(s) linking a contributor to its affiliation(s).
    def render_affiliation_refs(contributor)
      numbers = affiliation_numbers(contributor)
      return if numbers.blank?

      tag.sup(numbers.join(','), class: 'ms-1')
    end

    # A de-duplication key for an affiliation: its name and identifier.
    def affiliation_key(affiliation)
      [affiliation['name'], affiliation['affiliation_identifier']]
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
