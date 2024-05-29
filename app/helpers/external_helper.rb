module ExternalHelper
  def external_metadata(source, source_identifier)
    json_response = ExternalApis.new.retrieve_dataset_metadata(source, source_identifier)
    #display_metadata("Dryad", json_response)
    display_metadata(source, json_response)
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

  def display_redivis(json_response)
    display_metadata_json(json_response)
  end

  def display_datagov(json_response)
    display_metadata_json(json_response["result"])
  end

  def display_sdr(json_response)
    display_metadata_json(json_response)
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

end