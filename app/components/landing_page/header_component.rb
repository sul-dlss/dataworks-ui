# frozen_string_literal: true

module LandingPage
  class HeaderComponent < ::HeaderComponent
    def show_search_bar?
      false
    end

    def header_css_class
      ''
    end
  end
end
