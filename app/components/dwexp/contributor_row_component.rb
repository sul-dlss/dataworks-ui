module Dwexp
  class ContributorRowComponent < ViewComponent::Base
    def initialize(field:, contributor:)
      super()
      @field = field
      @contributor = contributor
    end

    private

    # Render the contributor's name with a link to search results
    def render_name
      tag.div do
        link_to(@contributor['name'], search_catalog_path(f: { @field.field_config.key => [@contributor['name']] })) +
        render_orcid_link +
        render_profile_link
      end
    end

    # Render the profile page URL with Stanford badge, if the contributor has one
    def render_profile_link
      return unless cap_id.present?

      link_to("https://profiles.stanford.edu/intranet/#{cap_id}", target: :blank) do
        tag.span("Stanford profile for #{@contributor['name']} ", class: 'visually-hidden') +
        tag.i(class:'ms-1 bi bi-person-fill profile')
      end
    end

    # Get all of the departments for an affiliation, excluding duplicates of the affiliation name
    def departments(affiliation)
      Array(affiliation['affiliation_department_name']).map do |dept|
        dept unless dept == affiliation['name']
      end.compact
    end

    # Render a link to an ORCID profile with the ORCID icon, if the contributor has one
    def render_orcid_link
      return unless orcid.present?

      link_to(orcid['name_identifier'], target: :blank) do
        tag.span("ORCID profile for #{@contributor['name']} ", class: 'visually-hidden') +
        image_tag('orcid_id.svg', alt: "", class: 'orcid-icon ms-2')
      end
    end

    # Render a link to a ROR profile with the ROR icon, if the affiliation has one
    def render_ror_link(affiliation)
      return unless affiliation['affiliation_identifier_scheme'] == 'ROR'

      link_to(affiliation['affiliation_identifier'], target: :blank) do
        tag.span("ROR profile for #{affiliation['name']} ", class: 'visually-hidden') +
        image_tag('ror_icon.svg', alt: "", class: 'ror-icon ms-2')
      end
    end

    # Render the affiliation country as an emoji flag using ROR info
    def render_affiliation_country(affiliation)
      return unless affiliation['affiliation_identifier_scheme'] == 'ROR'
      org = RorService.get_by_id(affiliation['affiliation_identifier'])
      return unless org&.country_name.present?

      tag.div(class: 'text-nowrap') do
        tag.span(org.country_name) +
        tag.span(org.country_emoji, class: 'ms-2', aria: { hidden: true })
      end
    end

    # Render a link to view the modal of collaborators for this contributor
    def render_collaborators_link
      link_to(collaborators_catalog_path(f: { 'contributors_ssim' => [@contributor['name']] }), data: { blacklight_modal: 'trigger', turbo: false }) do
        tag.i(class: "bi bi-people-fill me-1", aria: { hidden: true }) +
        tag.span(@contributor['name'], class: 'visually-hidden') +
        tag.span("Collaborators")
      end
    end

    private

    # The ORCID identifier for the contributor, if present
    def orcid
      @orcid ||= Array(@contributor['name_identifiers']).find { |id| id['name_identifier_scheme'] == 'ORCID' }&.dig('name_identifier')
    end

    # The Stanford Profiles (CAP) identifier for the contributor, if present
    def cap_id
      @cap_id ||= Array(@contributor['name_identifiers']).find { |id| id['name_identifier_scheme'] == 'CAP' }&.dig('name_identifier')
    end
  end
end
