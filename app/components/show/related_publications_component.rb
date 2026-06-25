# frozen_string_literal: true

module Show
  class RelatedPublicationsComponent < ViewComponent::Base
    # Resource types that are never treated as publications
    NON_PUBLICATION_TYPES = %w[Dataset Image Software ComputationalNotebook].freeze

    # Relationship types that are never treated as publications
    NON_PUBLICATION_RELATION_TYPES = %w[HasVersion IsVersionOf HasPart IsPartOf IsPreviousVersionOf
                                        IsNewVersionOf IsVariantFormOf IsIdenticalTo IsOriginalFormOf].freeze

    def initialize(document:)
      super()
      @related_items = document.struct_field('related_identifiers_struct_ss')
    end

    # Publications grouped under the relationship label we display them by
    def group_publications
      @group_publications ||= @related_items.select { |item| publication?(item) }
                                            .group_by { |item| relation_type_label(item) }
    end

    # Whether a related item should be shown as a publication.
    # For reference, types in our index so far
    # #<Set: {"Dataset", "", "Text", "Preprint", "JournalArticle", "Software", "Report",
    # "BookChapter", "Other", "Book", "ConferencePaper", "Dissertation", "InteractiveResource",
    # "Collection", "ComputationalNotebook", "ConferenceProceeding", "PeerReview",
    # "Journal", "Instrument", "Image"}>
    def publication?(item)
      NON_PUBLICATION_TYPES.exclude?(item['resource_type_general'] || '') &&
        NON_PUBLICATION_RELATION_TYPES.exclude?(item['relation_type'] || '')
    end

    def relation_type_label(item)
      return 'Journals' if item['related_identifier_type'] == 'ISSN'

      case item['relation_type'] || ''
      when '' then 'Publication'
      when 'IsCitedBy' then 'Cited by'
      when 'IsDescribedBy' then 'Described by'
      when 'Cites' then 'Cites'
      when 'References' then 'Reference'
      else 'Related resource'
      end
    end

    def openalex_info_url
      "#{root_path}openalex_info"
    end

    def render?
      group_publications.present?
    end

    # PMID ids ending with .0 are not allowing for any responses from OpenAlex
    def parse_id(id, type)
      return id.delete_suffix('.0') if type == 'PMID'

      id
    end
  end
end
