# frozen_string_literal: true

# Backs the contributor detail modal opened from a dataset's show page.
module ContributorModal
  extend ActiveSupport::Concern

  # Render the contributor detail modal for the given contributor
  def contributor
    load_contributor_data

    respond_to do |format|
      format.html { render layout: !request.xhr? }
    end
  end

  private

  def load_contributor_data
    @facet = contributor_facet
    @contributors = contributor_params(@facet)
    raise ActionController::RoutingError, 'Not Found' if @contributors.blank?

    @response = contributor_response(@facet, @contributors)
    @display_facet = @response.aggregations[@facet.key]
    @presenter = @facet.presenter.new(@facet, @display_facet, view_context)
    @document = contributor_document
    @records = contributor_records
  end

  # The dataset being viewed, if any, for pulling contributor details.
  def contributor_document
    return if params[:id].blank?

    search_service.fetch(params[:id])
  rescue Blacklight::Exceptions::RecordNotFound
    nil
  end

  # Full contributor records (name, identifiers, affiliations) for the modal's contributor(s).
  def contributor_records
    return [] if @document.blank?

    @document.contributors.select { |contributor| @contributors.include?(contributor['name']) }
  end

  def contributor_facet
    blacklight_config.facet_fields['contributors_ssim']
  end

  def contributor_params(facet)
    params.dig(:f, facet.key)
  end

  def contributor_response(facet, contributors)
    search_service.facet_field_response(
      facet.key,
      {
        "f[#{facet.key}][]" => contributors,
        "f.#{facet.key}.facet.limit" => -1,
        'facet.sort' => 'count'
      }
    )
  end
end
