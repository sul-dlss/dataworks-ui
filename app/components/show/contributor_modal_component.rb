# frozen_string_literal: true

module Show
  class ContributorModalComponent < Blacklight::System::ModalComponent
    include AffiliationPresentation

    ORCID_URL_BASE = 'https://orcid.org/'
    STANFORD_PROFILE_URL_BASE = 'https://profiles.stanford.edu/intranet/'
    ORCID_SCHEME = 'ORCID'
    CAP_SCHEME = 'CAP'

    def initialize(contributors:, facet:, records: [])
      super()
      @contributors = contributors
      @facet = facet
      @records = records
      @items = facet.display_facet.items
    end

    # Affiliations recorded across the modal's contributor record(s).
    def affiliations
      @records.flat_map { |record| Array(record['affiliation']) }
    end

    def datasets_count
      @items.filter_map { |item| item.hits if @contributors.include? item.value }.sum
    end

    # The single contributor record backing the modal, whose ORCID and Stanford
    # profile links appear in the header. Absent when the name resolves to more
    # than one record (differing identifiers), where the correct one is ambiguous.
    def contributor_record
      @records.first if @records.one?
    end

    # Render a link to the contributor's ORCID profile, if present.
    def render_orcid_link(record)
      url = orcid_url(record)
      return if url.blank?

      link_to(url, class: 'orcid-record', target: :blank) do
        tag.span(t('.orcid_aria_label', name: record['name']), class: 'visually-hidden') +
          render(Icons::OrcidComponent.new(aria_hidden: true)) +
          tag.span(t('.orcid_record'), class: 'orcid-record__label fs-6 fw-normal', aria: { hidden: true })
      end
    end

    # Render the contributor's Stanford profile link with an icon and label, if present.
    def render_profile_link(record)
      id = cap_id(record)
      return if id.blank?

      link_to("#{STANFORD_PROFILE_URL_BASE}#{id}", class: 'profile-link', target: :blank) do
        tag.span(t('.stanford_profile_aria_label', name: record['name']), class: 'visually-hidden') +
          render(Icons::PersonFillComponent.new(classes: 'profile-icon ms-3', aria_hidden: true)) +
          tag.span(t('.stanford_profile'), class: 'profile-link__label fs-6 fw-normal', aria: { hidden: true })
      end
    end

    # The ORCID profile URL for a contributor, if present.
    def orcid_url(record)
      value = name_identifier(record, ORCID_SCHEME)
      return if value.blank?
      return value if value.start_with?('http')

      "#{ORCID_URL_BASE}#{value}"
    end

    # The Stanford Profiles (CAP) identifier for a contributor, if present.
    def cap_id(record)
      name_identifier(record, CAP_SCHEME)
    end

    # The identifier value recorded under the given scheme on a contributor record.
    def name_identifier(record, scheme)
      Array(record['name_identifiers']).find do |id|
        id['name_identifier_scheme'] == scheme
      end&.dig('name_identifier')
    end

    # The departments listed for an affiliation, excluding repeats of the affiliation name.
    def departments(affiliation)
      Array(affiliation['affiliation_department_name']).reject { |dept| affiliation['name'].include?(dept) }
    end

    def collaborators
      @items.reject { |item| @contributors.include? item.value }.map do |item|
        Blacklight::FacetItemPresenter.new(
          item,
          @facet.facet_field,
          @facet.view_context,
          @facet.key,
          @facet.search_state
        )
      end
    end
  end
end
