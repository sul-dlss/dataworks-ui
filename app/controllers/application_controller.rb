# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include BotChallengePage::Controller

  # Adds a few additional behaviors into the application controller
  include Blacklight::Controller

  layout :determine_layout if respond_to? :layout

  # Guard against malformed `view` params (e.g. `?view[]=1`), which Rails parses
  # as an Array/Hash. Blacklight's document_index_view_type helper calls
  # `view_param.to_sym`, so a non-scalar value raises NoMethodError and 500s.
  before_action :sanitize_view_param

  private

  def sanitize_view_param
    # rubocop:disable Rails/StrongParametersExpect
    params.delete(:view) unless params[:view].respond_to?(:to_sym)
    # rubocop:enable Rails/StrongParametersExpect
  end
end
