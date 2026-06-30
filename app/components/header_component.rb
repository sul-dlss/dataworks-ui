# frozen_string_literal: true

class HeaderComponent < Blacklight::HeaderComponent
  def show_search_bar?
    true
  end

  def header_css_class
    'mb-3'
  end
end
