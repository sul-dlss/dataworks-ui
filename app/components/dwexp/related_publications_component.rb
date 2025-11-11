module Dwexp
  class RelatedPublicationsComponent < ViewComponent::Base
    def initialize(document:)
      super()
      @document = document
      @related_items = JSON.parse(document['related_identifiers_struct_ss'] || '[]')
      @group_all = {}
      @group_publications = {}
      group_related_items
    end

    # Retrieve related items and then organize by type of relationship
    def group_related_items
      @related_items.each do |val|
        id = val['related_identifier']
        relation_type = val['relation_type'] || ''
        related_identifier_type = val['related_identifier_type'] || ''

        @group_all[relation_type] = [] if ! @group_all.key?(relation_type)
        @group_all[relation_type] << val

        # For publications, we group by what we will call the relationship type for display
        if add_publication(val)
          display_relation_type = relation_type_label(relation_type, related_identifier_type)
          @group_publications[display_relation_type] = []  if ! @group_publications.key?(display_relation_type)
          @group_publications[display_relation_type] << val
        end
      end
    end

    # If the related item is absolutely NOT a publication, we don't want to add to our list
    # For reference, types in our index so far
    # #<Set: {"Dataset", "", "Text", "Preprint", "JournalArticle", "Software", "Report", 
    # "BookChapter", "Other", "Book", "ConferencePaper", "Dissertation", "InteractiveResource", 
    # "Collection", "ComputationalNotebook", "ConferenceProceeding", "PeerReview", 
    # "Journal", "Instrument", "Image"}>
    def add_publication(related_item_info)
      # Type of related item
      item_type = related_item_info['resource_type_general'] || ''
      # Relationship type
      relation_type = related_item_info['relation_type'] || ''

      !( non_publication_types.include?(item_type) || non_publication_relation_types.include?(relation_type) ) 
    end

    def non_publication_types
      ['Dataset', 'Image', 'Software', 'ComputationalNotebook']
    end

    def non_publication_relation_types
      ['HasVersion', 'IsVersionOf', 'HasPart', 'IsPartOf', 'IsPreviousVersionOf', 'IsNewVersionOf',
    'IsVariantFormOf', 'IsIdenticalTo', 'IsOriginalFormOf']
    end

    def relation_type_label(relation_type, related_identifier_type)
      return 'Journals' if related_identifier_type == 'ISSN'

      case relation_type
      when ''
        'Publications'
      when 'IsCitedBy'
        'Cited By'
      when 'IsDescribedBy'
        'Described By'
      when 'Cites'
        'Cites'
      else
        'Related resources'
      end
    end

    def openalex_info_url
      "#{root_path}openalex_info" 
    end

    def render?
      @group_publications.present?
    end
  end
end