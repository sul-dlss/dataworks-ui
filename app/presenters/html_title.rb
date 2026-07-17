# frozen_string_literal: true

# Renders the document title from an Solr field containing HTML markup
# (e.g. title_html_tsm).
#
# For HTML requests we mark the value html_safe so link_to / DocumentTitleComponent
# emit the markup instead of escaping it. For every other format (JSON API, Atom/RSS)
# we strip tags so consumers get plain text rather than raw markup.
module HtmlTitle
  ALLOWED_TAGS = %w[i em sub sup].freeze

  def heading
    value = super
    return value if value.blank?

    if html_request?
      view_context.sanitize(value, tags: ALLOWED_TAGS, attributes: [])
    else
      view_context.strip_tags(value)
    end
  end

  private

  def html_request?
    view_context.respond_to?(:request) && view_context.request&.format&.html?
  end
end
