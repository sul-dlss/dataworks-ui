module ExternalHelper
  def external_metadata(source, source_identifier)
    json_response = ExternalApis.new.retrieve_dataset_metadata(source, source_identifier)
    provider_url(source, json_response) + display_metadata(source, json_response)
  end

  def display_metadata(source, json_response)
    case source
    when "Dryad"
      display_dryad(json_response)
    when "DataCite"
      display_datacite(json_response)
    when "Redivis"
      display_redivis(json_response)
    when "Data.gov"
      display_datagov(json_response)
    when "SDR"
      display_sdr(json_response)
    when "Zenodo"
      display_zenodo(json_response)
    when "SearchWorks"
      display_searchworks(json_response)
    when "OpenAlex"
      display_openalex(json_response)
    end
  end

  # Source specific display

  # Dryad
  def display_dryad(json_response)
    display_html = ""
    # Don't display links
    json_response.each do |json_field, json_value|
      next if(json_field == "_links")

      display_html += generate_field_heading(json_field) + generate_field_content(json_field, json_value)

    end
    sanitize '<dl class="document-metadata dl-invert row">' + display_html + "</dl>"
  end

  # DataCite
  def display_datacite(json_response)
    # Focus on attributes where the main metadata we map resides
    attributes_response = json_response["data"]["attributes"]
    display_metadata_json(attributes_response)
  end

  def display_openalex(json_response)
    display_metadata_json(json_response)
  end

  def display_redivis(json_response)
    display_metadata_json(json_response)
  end

  def display_datagov(json_response)
    display_metadata_json(json_response["result"])
  end

  def display_sdr(json_response)
    display_metadata_json(json_response)
  end

  def display_zenodo(json_response)
    display_metadata_json(json_response)
  end

  def display_searchworks(json_response)
    display_metadata_json(json_response["response"]["document"])
  end
  # Generate Blacklight like display for metadata
  # Display whatever json object we pass through
  def display_metadata_json(json_response)
    display_html = ""
    # Focus on attributes where the main metadata we map resides
    json_response.each do |json_field, json_value|
      display_html += generate_field_heading(json_field) + generate_field_content(json_field, json_value)
    end
    sanitize '<dl class="document-metadata dl-invert row">' + display_html + "</dl>"
  end

  def generate_field_heading(name)
    "<dt class='blacklight-#{name} col-md-3'>#{name}</dt>"
  end

  def generate_field_content(name, value)
    display_value = value.to_s
    if value.is_a?(Array)
      display_value = display_embedded_array(value)
    end
    "<dd class='col-md-9 blacklight-#{name}'>#{display_value}</dd>"
  end

  def display_embedded_array(array_content)
    array_content.map do |entry|
      if entry.is_a?(Hash)
        display_embedded_hash(entry)
      else
        entry.to_s
      end
    end.join("<br><br>")
  end
  # When field value is nested
  def display_embedded_hash(hash_content)
    hash_content.map do |key, value|
      "#{key}: #{value.to_s}"
    end.join("<br>")
  end

  # Dataset preview
  def display_preview(dataset_download_url)
    ExternalApis.new.dataset_preview(dataset_download_url)
  end

  # Get the URL
  def external_metadata_url(source, source_identifier)
     ExternalApis.new.metadata_url(source, source_identifier)
  end

  # Get the URL (where possible) for the page at the provider
  def provider_url(source, json_response)
    url = case source
    when "Dryad"
      "https://datadryad.org/dataset/#{json_response['identifier']}" 
    when "DataCite"
      "https://commons.datacite.org/doi.org/#{json_response["data"]["attributes"]["doi"]}"
    when "Redivis"
      "https://redivis.com/datasets/#{json_response['id']}"
    when "Data.gov"
      ''
    when "SDR"
      ''
    when "Zenodo"
      "https://zenodo.org/records/#{json_response['id']}"
    when "SearchWorks"
      "https://searchworks.stanford.edu/view/#{json_response['response']['document']['id']}"
    when "OpenAlex"
      "https://openalex.org/works/#{json_response['id']['https://openalex.org/'.length,json_response['id'].length]}"
    end
    sanitize "<a href='#{url}'>Provider url</a>"
  end

  # From the other provider hash added to the solr doc, everything is in lower case
  def provider_url_link_for_id(source, id)
    url = case source
    when "dryad"
      "https://datadryad.org/dataset/#{id}" 
    when "datacite"
      "https://commons.datacite.org/doi.org/#{id}"
    when "redivis"
      "https://redivis.com/datasets/#{id}"
    when "zenodo"
      "https://zenodo.org/records/#{id}"
    when "searchworks"
      "https://searchworks.stanford.edu/view/#{id}"
    when "open_alex"
      "https://openalex.org/works/#{id['https://openalex.org/'.length,id.length]}"
    end
    url
  end

end