class Datacite  
  require 'net/http'

  # Initialize independent of the specific URI to be used
  def initialize
    # This is the base for the REST API
    @base_datasets_url = "https://api.datacite.org/dois/"
  end

  # This is not necessarily a single "file" but dataset as defined by the service
  def retrieve_metadata(source_identifier_ssi)
    # Which identifier do we use to retrieve the data    
    json_response(@base_datasets_url + source_identifier_ssi)
  end

  def json_response(url)
    resp = Net::HTTP.get_response(URI.parse(url))
    data = resp.body
    JSON.parse(data)
  end
end