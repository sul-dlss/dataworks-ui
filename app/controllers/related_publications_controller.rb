# frozen_string_literal: true

# Controller that handles request to retrieve information about related publications
class RelatedPublicationsController < ApplicationController
  # Get info from Open Alex API regarding particular DOIs or identifiers
  def openalex_info
    id = params[:id]
    type = params[:type] || 'doi'
    response = {}

    if id.present?
      oa = Openalex.new
      response = oa.retrieve_metadata_by_id(id:, type:)
    end
    render json: response
  end
end