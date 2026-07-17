# frozen_string_literal: true

module DataworksHelper
  def display_remaining_keys(val, exclude_keys)
    display_string = val.filter_map do |key, value|
      next if exclude_keys.include?(key)

      "#{key}: #{value}"
    end.join(', ')
    display_string = ", #{display_string}" if display_string.length.positive?
    display_string
  end

  # For funding information
  def display_funding_information(args)
    # args[:value] appears to always be an array, even when the field is single valued in Solr
    info = args[:value].map do |arg|
      parsed_json = JSON.parse(arg)
      # This is an array of objects
      parsed_json.map do |val|
        funder_name = val.key?('funder_name') ? val['funder_name'] : ''
        award_number = val.key?('award_number') ? ", Award number #{val['award_number']}" : ''
        award_uri = val.key?('award_uri') ? ", #{val['award_uri']}" : ''
        # add_facet_link('funders_ssim', funder_name)
        "#{add_facet_link('funders_ssim',
                          funder_name)}#{award_number}#{award_uri}#{display_remaining_keys(val,
                                                                                           %w[funder_name
                                                                                              award_number award_uri])}"
      end.join('<br>')
    end.join

    info.html_safe
  end

  def add_facet_link(facet_field, facet_value)
    link_to(facet_value, search_action_path(search_state.filter(facet_field).add(facet_value)))
  end

  def display_variables(args)
    args[:value].map(&:titleize).sort.join('<br>').html_safe
  end

  # Collapse a list of temporal coverage years into ranges of consecutive years.
  # e.g. [1990, 1991, 1992, 1995] => "1990–1992, 1995"
  def display_temporal_coverage(args)
    years = Array(args[:value]).map(&:to_i).uniq.sort
    return if years.empty?

    years.slice_when { |prev, curr| curr > prev + 1 }.map do |group|
      group.length == 1 ? group.first.to_s : "#{group.first}–#{group.last}"
    end.join(', ')
  end

  # Define allowed tags and attributes for sanitization
  ALLOWED_TAGS = %w[a b i em strong p ul ol li br table thead tbody tr th td colgroup col].freeze
  ALLOWED_ATTRIBUTES = %w[href].freeze

  # Sanitize HTML/XML in rich text fields and render line breaks.
  def render_rich_text(args)
    safe_join(args[:value].map do |arg|
      # If there are newlines in between tags or in running text, they will get
      # converted to <br> tags by simple_format, which we don't want. We sanitize
      # first, then clean up any undesired newlines that may result.
      input = sanitize(CGI.unescapeHTML(arg), tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES)
        .gsub(/>\n+\s*</, '><')
        .gsub(/([^>])\n ([^<])/, '\1 \2')

      # We wrap each value in a div with class 'rich-text' so that we can
      # scope styling to just these fields. The default is <p>, but that
      # causes issues when the content itself contains <p> tags.
      simple_format(
        input,
        { class: 'rich-text' },
        wrapper_tag: :div,
        sanitize_options: { tags: ALLOWED_TAGS, attributes: ALLOWED_ATTRIBUTES }
      )
    end)
  end
end
