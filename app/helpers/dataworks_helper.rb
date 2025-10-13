module DataworksHelper
  # Try to render a human-readable display of related identifier information
  def render_related_identifiers(args)
    # Convert into array of objects
    args[:value].map do |arg|
        parsed_json = JSON.parse(arg)
        parsed_json.map do |val|
            prefix_string = ""
            relation_type = ""
            id = "#{val['related_identifier']}"
            if(val.key?('relation_type')) 
                relation_type = "#{val['relation_type']}: "
            end
            if(val.key?('related_identifier_type')) 
                prefix_string = "#{relation_type}#{val['related_identifier_type']}"
            end
            "#{prefix_string} #{id} #{display_remaining_keys(val, ['related_identifier', 'relation_type', 'related_identifier_type'])}"
            # Display any other keys after
        end.join('<br>')
    end.join('').html_safe
    
  end

  def display_remaining_keys(val, exclude_keys)
    display_string = val.filter_map do |key, value|
        next if exclude_keys.include?(key)

        "#{key}: #{value}"

    end.join(', ')
    if display_string.length > 0
        display_string = ", #{display_string}"
    end
    display_string
  end

  # For funding information
  def display_funding_information(args)
    # args[:value] appears to always be an array, even when the field is single valued in Solr
    info = args[:value].map do |arg|
        parsed_json = JSON.parse(arg)
        # This is an array of objects
        parsed_json.map do |val|
            funder_name = val.key?('funder_name')? val['funder_name'] : ''
            award_number = val.key?('award_number')? ", Award number #{val['award_number']}" : ''
            award_uri = val.key?('award_uri')? ", #{val['award_uri']}" : ''
            #add_facet_link('funders_ssim', funder_name)
            "#{add_facet_link('funders_ssim', funder_name)}#{award_number}#{award_uri}#{display_remaining_keys(val, ['funder_name', 'award_number', 'award_uri'])}"
        end.join('<br>')
    end.join('')

    info.html_safe
  end

  def add_facet_link(facet_field, facet_value)
    url =  "/?f[#{facet_field}][]=#{facet_value}"
    link_to(facet_value, url)
  end

  # Render creators info
  def render_creators_contributors(args)
     # args[:value] appears to always be an array, even when the field is single valued in Solr
    facet_field = (args[:field] == 'creators_struct_ss') ? 'creators_ssim': 'contributors_ssim'
     info = args[:value].map do |arg|
        parsed_json = JSON.parse(arg)
        parsed_json.map do |val|
            name = val.key?('name')? val['name'] : ''
            "#{add_facet_link(facet_field, name)}#{display_name_identifiers(val)}#{display_affiliation_info(val)}"
        end.join('<br>')
        
    end.join('')
    
    info.html_safe
  end

  def display_name_identifiers(val)
    return '' if ! val.key?('name_identifiers')

    ids = val['name_identifiers'].filter_map do |nid|
        next if nid['name_identifier'].blank?

        name_identifier_scheme = nid['name_identifier_scheme'] || ''

        if(name_identifier_scheme == 'ORCID')
            display_orcid_link(nid['name_identifier'])
        elsif(name_identifier_scheme.length > 0)
            "#{name_identifier_scheme} : #{nid['name_identifier']}"
        else
            nid['name_identifier']
        end
    end.join(', ')

    ids.length > 0 ? " (#{ids})" : ''
  end

  def display_orcid_link(orcid)
    orcid_link = orcid
    if( ! orcid.starts_with?('https://orcid.org'))
        orcid_link = "https://orcid.org/#{orcid_link}"
    end
    link_to('ORCID', orcid_link, target: :blank)
  end

  def display_affiliation_info(val)
    return '' if val['affiliation'].blank?

    affiliations = val['affiliation'].filter_map do |a|
        next unless a['name'].present?

        a['name']
    end.join(', ')

    affiliations.empty? ? '' : " (#{affiliations})"
  end

  def url_link(args)
    link_to(args[:value][0], args[:value][0], target: :blank)
  end

  def display_dates(args)
    args[:value].map do |arg|
        parsed_json = JSON.parse(arg)
        parsed_json.map do |val|
            display = val['date']
            display = "#{val['date_type']}: #{display}" if val['date_type'].present?
        end.join('<br>')
    end.join(' ').html_safe
  end

  def display_rights(args)
    args[:value].map do |arg|
        parsed_json = JSON.parse(arg)
        parsed_json.map do |val|
            rights = val['rights'] || ''
            rights_uri = val['rights_uri'] || ''
            rights_identifier = val['rights_identifier'] || ''
            rights_identifier_scheme = val['rights_identifier_scheme'] || ''
            rights_link = rights_uri.present? ? ", #{link_to('URI', rights_uri)}" : ''
            rights_identifier_display = rights_identifier_scheme.present? ? ", #{rights_identifier_scheme}: #{rights_identifier}" : rights_identifier
            "#{rights}#{rights_link} #{rights_identifier_display}"
        end.join('<br>')
    end.join(' ').html_safe
  end

  def display_variables(args)
    args[:value].map(&:titleize).sort.join('<br>').html_safe
  end

  def display_facet_separate_lines(args)
    field = args[:field]
    args[:value].sort.map do|val|
      add_facet_link(field, val)
    end.join('<br>').html_safe
  end

  def display_also_available(args)
    doc = args[:document]
    url = doc['url_ss']
    # Filter out any providers that are already in the main URL
    args[:value].map do |arg|
      parsed_json = JSON.parse(arg)
      parsed_json.map do |provider, id|
        next if url.include?(provider.downcase)
          
        "<a target='_blank' href='#{provider_url_link_for_id(provider.downcase, id)}'>#{provider.titleize}</a>"
      end.compact.join('<br>')
    end.join('').html_safe
  end

  # Sanitize HTML/XML in rich text fields and render line breaks.
  def render_rich_text(args)
    safe_join(args[:value].map do |arg|
      simple_format(
        # If there is whitespace in between tags, they will get converted to <br>
        # by simple_format, which results in bad list rendering. This preserves
        # newlines in running text but removes them between tags.
        arg.gsub(/(<[^>]+?>)\s+(?=<[^>]+?>)/, "\\1"),
        # We wrap each value in a div with class 'rich-text' so that we can
        # scope styling to just these fields. The default is <p>, but that
        # causes issues when the content itself contains <p> tags.
        { class: 'rich-text' },
        wrapper_tag: :div,
        sanitize_options: { tags: %w(p b i em strong ul ol li br a), attributes: %w(href) }
      )
    end)
  end
end
