# frozen_string_literal: true

module Feedback
  # Shared referer handling for the feedback form components.
  module WithReferer
    # The submitting page, used for display and the hidden url field. The Referer
    # header is a raw, user-controlled ASCII-8BIT (BINARY) string; rendering it
    # directly can poison the UTF-8 output buffer and raise
    # Encoding::CompatibilityError, so coerce it to valid UTF-8 first. Nil when
    # there is no referer.
    def referer
      return unless (url = request.referer.presence)

      url.dup.force_encoding('UTF-8').scrub
    end
  end
end
