# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Malformed view param handling' do
  # A crawler hitting `?view[]=1` makes Rails parse `view` as an Array, which
  # previously reached Blacklight's document_index_view_type helper (rendered by
  # the header on every page) and raised
  # `NoMethodError: undefined method 'to_sym' for an instance of Array`.
  describe 'when view is a non-scalar value' do
    it 'does not 500 with an array view param' do
      get '/search_history?view[]=1'

      expect(response).to have_http_status(:ok)
    end

    it 'does not 500 with a hash view param' do
      get '/search_history?view[foo]=1'

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'when view is a valid scalar value' do
    it 'still honors a normal string view param' do
      get '/search_history?view=list'

      expect(response).to have_http_status(:ok)
    end
  end
end
