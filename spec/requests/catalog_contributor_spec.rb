# frozen_string_literal: true

require 'rails_helper'

# The contributor detail modal endpoint.
RSpec.describe 'Catalog contributor' do
  # A crawler hitting `/catalog/contributor` with no facet params made
  # `params[:f]` nil, which previously raised
  # `NoMethodError: undefined method '[]' for nil`.
  describe 'when no contributor facet params are present' do
    it 'returns 404 rather than 500' do
      get contributor_catalog_path

      expect(response).to have_http_status(:not_found)
    end

    it 'returns 404 when the f param is present but has no contributors' do
      get contributor_catalog_path(f: {})

      expect(response).to have_http_status(:not_found)
    end
  end
end
