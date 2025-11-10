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

    # Render the profile page URL with Stanford badge
    def render_profile_link
      return '' unless @contributor['name_identifiers'].present?

      cap_id = @contributor['name_identifiers'].filter_map do |nid|
        nid['name_identifier'] if nid['name_identifier_scheme'].present? && nid['name_identifier_scheme'] == 'CAP'
      end

      return '' unless cap_id.present? 

      link_to("https://profiles.stanford.edu/intranet/#{cap_id[0]}", target: :blank) do
        tag.span("Stanford profile for #{@contributor['name']} ", class: 'visually-hidden') +
        tag.i(class:'ms-1 bi bi-person-fill profile')
      end
    end

    # Render an affiliation with its ROR link and country if present
    def render_affiliation(affiliation)
      tag.div do
        tag.span(render_affiliation_name(affiliation)) +
        render_affiliation_country(affiliation).to_s +
        render_ror_link(affiliation)
      end
    end

    # Render affiliation name with department name if available 
    def render_affiliation_name(affiliation)
      name = affiliation['name']
      department_names = include_department_names(name, affiliation['affiliation_department_name'])

      if department_names.present?
        return "#{name}, #{department_names.join(', ')}"
      end

      name
    end

    # Render department names only if the text of the name is not already included in the affiliation
    def include_department_names(affiliation_name, department_names)
      return unless department_names.present?

      department_names.filter_map do |department_name|
        department_name if ! affiliation_name.include?(department_name)
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
