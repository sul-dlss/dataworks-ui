# frozen_string_literal: true

module Icons
  class BoxArrowUpLeftComponent < Blacklight::Icons::IconComponent
    self.svg = <<~SVG
      <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" fill="currentColor" class="bi bi-box-arrow-up-left" viewBox="0 0 16 16">
        <path fill-rule="evenodd" d="M7.364 3.5H14.5a.5.5 0 0 1 .5.5v10a.5.5 0 0 1-.5.5H4a.5.5 0 0 1-.5-.5V6.636l-1 1V14a1.5 1.5 0 0 0 1.5 1.5h11A1.5 1.5 0 0 0 16 14V4a1.5 1.5 0 0 0-1.5-1.5H6.364z"/>
        <path fill-rule="evenodd" d="M0 1.5A.5.5 0 0 1 .5 1H6a.5.5 0 0 1 0 1H1.707l8.147 8.146a.5.5 0 0 1-.708.708L1 2.707V6.5a.5.5 0 0 1-1 0z"/>
      </svg>
    SVG
  end
end
