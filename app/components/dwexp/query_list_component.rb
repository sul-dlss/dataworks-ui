module Dwexp
    class QueryListComponent < ViewComponent::Base
        def initialize(query:, sort: nil)
            super
            @query = query
            @sort = sort
            response = results['response']
            @docs = response['docs']
          end
        
        def search_params
            {
                'q' => @query,
                'rows' => 4,
                'fl' => '*',
                'sort' => @sort
            }.compact
        end
    
        def results
            solr = RSolr.connect url: Blacklight.connection_config[:url]
            @results = solr.get 'select', params: search_params
        end

    end
  end


  