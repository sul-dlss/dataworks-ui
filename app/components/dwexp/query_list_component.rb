module Dwexp
    class QueryListComponent < ViewComponent::Base
        def initialize(query:, sort: nil)
            super
            @query = query
            @sort = sort
            response = results['response']
            @docs = filter_titles(response['docs'])
          end
        
        def search_params
            {
                'q' => @query,
                'rows' => 30,
                'fl' => '*',
                'sort' => @sort
            }.compact
        end
    
        def results
            solr = RSolr.connect url: Blacklight.connection_config[:url]
            @results = solr.get 'select', params: search_params
        end

        def filter_titles(docs)
            # Get rid of any docs that have the same title in the display
            # This is just a temporary solution
            return_docs = []
            doc_titles = []
            docs.each do |doc|
                title = doc['title_tsim']
                if ! doc_titles.include?(title)
                    doc_titles.push(title)
                    return_docs.push(doc)
                end
            end

            if return_docs.length <= 4
                return return_docs
            else
                return return_docs[0..3]
            end
        end

    end
  end


  