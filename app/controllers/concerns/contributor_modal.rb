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
    @response = contributor_response(@facet, @contributors)
    @display_facet = @response.aggregations[@facet.key]
    @presenter = @facet.presenter.new(@facet, @display_facet, view_context)
    @affiliations = contributor_affiliations
  end

  # Affiliations recorded for the contributor(s) on the dataset being viewed.
  def contributor_affiliations
    return [] if params[:id].blank?

    document = search_service.fetch(params[:id])
    @contributors.flat_map { |name| document.affiliations_for(name) }
  rescue Blacklight::Exceptions::RecordNotFound
    []
  end

  def contributor_facet
    blacklight_config.facet_fields['contributors_ssim']
  end

  def contributor_params(facet)
    params[:f][facet.key]
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
