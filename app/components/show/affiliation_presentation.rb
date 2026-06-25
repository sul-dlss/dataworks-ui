# frozen_string_literal: true

module Show
  # Rendering helpers shared by components that display contributor affiliations.
  module AffiliationPresentation
    # Render a link to an affiliation's ROR profile with the ROR icon, if present.
    def render_ror_link(affiliation)
      return unless affiliation['affiliation_identifier_scheme'] == 'ROR'

      label = t('show.affiliation_presentation.ror_aria_label', name: affiliation['name'])
      link_to(affiliation['affiliation_identifier'], target: :blank) do
        tag.span(label, class: 'visually-hidden') +
          render(Icons::RorComponent.new(classes: 'ms-2', aria_hidden: true))
      end
    end

    # An affiliation's country/location name, via ROR, if available. The show
    # page and modal lay it out differently, so each renders the value itself.
    def affiliation_country(affiliation)
      return unless affiliation['affiliation_identifier_scheme'] == 'ROR'

      org = RorService.get_by_id(affiliation['affiliation_identifier'])
      org&.country_name.presence
    end
  end
end
