module Dwexp
    class QueryListComponent < ViewComponent::Base
        def initialize(query:, sort: nil)
            super
            @query = query
            @sort = sort
            response = results['response']
            @docs = filter_versions(response['docs'])
          end
        
        def search_params
            {
                'q' => @query,
                'rows' => 20,
                'fl' => '*',
                'sort' => @sort
            }.compact
        end
    
        def results
            solr = RSolr.connect url: Blacklight.connection_config[:url]
            @results = solr.get 'select', params: search_params
        end

        def filter_versions(docs)
            # Eliminate anything that says 'hasVersion' b/c that has a more recent version
            # We may not want to do this in actuality, this is just for temporary display
            return_docs = []
            puts docs.length.to_s
            docs.each do |doc|
                if doc.key?('related_identifiers_struct_ss') 
                    struct_array = JSON.parse(doc['related_identifiers_struct_ss'])
                    struct_array.each do |struct|
                        if(struct.key?('relation_type')) 
                            relation_type = struct['relation_type']
                            if relation_type != 'HasVersion'
                                return_docs << doc
                            end
                        else
                            return_docs << doc
                        end
                    end 
                else
                    return_docs << doc
                end
            end
            puts return_docs.length.to_s
            if return_docs.length <= 4
                return return_docs
            else 
                return_docs[0..3]
            end
        end

    end
  end


  