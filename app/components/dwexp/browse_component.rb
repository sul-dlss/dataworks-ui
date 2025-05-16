module Dwexp
    class BrowseComponent < ViewComponent::Base
        def initialize(facet_field:, display_type:, view_all:nil)
            super
            @facet_field = facet_field
            @display_type = display_type
            @view_all = view_all
            response = results['response']
            @facet_field_counts = results['facet_counts']['facet_fields'][@facet_field]
          end
        
        def search_params
            {
                'facet.field' => @facet_field,
                'facet' => true,
                'rows' => 0,
                'fl' => '*'
            }
        end

        def facet_field_search
            "#{@facet_field}:*"
        end
    
        def results
            solr = RSolr.connect url: Blacklight.connection_config[:url]
            @results = solr.get 'select', params: search_params
        end

    end
  end


  