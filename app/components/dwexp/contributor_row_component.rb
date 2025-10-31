module Dwexp
  class ContributorRowComponent < ViewComponent::Base
    def initialize(field:, contributor:)
      super()
      @field = field
      @contributor = contributor
    end

    private

    # Render the contributor's name with a link to search results
    # Adds a "Creator" asterisk if applicable
    def render_name
      tag.div do
        link_to(@contributor['name'], search_catalog_path(f: { @field.field_config.key => [@contributor['name']] })) +
        (tag.span("*", aria: { label: "Creator" }, class: "fw-normal") if @contributor['role'] == 'Creator') +
        render_orcid_link
      end
    end

    # Render an affiliation with its ROR link and country if present
    def render_affiliation(affiliation)
      tag.div do
        tag.span(affiliation['name']) +
        render_affiliation_country(affiliation).to_s +
        render_ror_link(affiliation)
      end
    end

    # Render a link to an ORCID profile with the ORCID icon, if the contributor has one
    def render_orcid_link
      orcid = Array(@contributor['name_identifiers']).find { |id| id['name_identifier_scheme'] == 'ORCID' }
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

      tag.span(org.country_emoji, class: 'ms-2', aria: { label: org.country_name }) if org&.country_emoji
    end
  end
end
