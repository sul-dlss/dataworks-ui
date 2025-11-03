class Openalex
    require 'net/http'
  
    # Initialize independent of the specific URI to be used
    def initialize
      # This is the base for the REST API
      @base_datasets_url = "https://api.openalex.org/works/"
    end
  
    # This is not necessarily a single "file" but dataset as defined by the service
    def retrieve_metadata(source_identifier_ssi)
      # Which identifier do we use to retrieve the data    
      prefix = 'https://openalex.org/'
      json_response(metadata_url(source_identifier_ssi[prefix.length, source_identifier_ssi.length]))
    end

    # Retrieve metadata given a particular doi
    def retrieve_metadata_by_id(id:, type: 'doi')
      path = "#{@base_datasets_url}https://doi.org/#{id}?select=id,title,doi,publication_year"
      json_response(path)
    end
  
    def json_response(url)
      resp = Net::HTTP.get_response(URI.parse(url))
      data = resp.body
      JSON.parse(data)
    end
  
    def metadata_url(source_identifier_ssi)
      @base_datasets_url + source_identifier_ssi
    end
  end