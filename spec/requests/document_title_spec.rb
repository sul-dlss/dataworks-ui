# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Document title rendering' do
  let(:html_doc_id) { '10_5061_dryad_ngf1vhhrp' }
  let(:plain_title) do
    'Association of CSF biomarkers with hippocampal-dependent memory in preclinical Alzheimer disease V1'
  end
  let(:no_html_title_doc_id) { 'redivis-123' }

  describe 'HTML views' do
    it 'renders the title markup on the search results page' do
      get search_catalog_path(q: 'Alzheimer')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('disease <em>V1</em>')
    end

    it 'renders the title markup on the show page' do
      get solr_document_path(html_doc_id)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('disease <em>V1</em>')
    end
  end

  describe 'JSON API' do
    it 'returns the title as plain text on the index endpoint' do
      get search_catalog_path(q: 'Alzheimer', format: :json)

      titles = response.parsed_body['data'].map { |doc| doc.dig('attributes', 'title') }
      expect(titles).to include(plain_title)
    end

    it 'returns the title as plain text on the show endpoint' do
      get solr_document_path(html_doc_id, format: :json)

      expect(response.parsed_body.dig('data', 'attributes', 'title')).to eq(plain_title)
    end
  end

  describe 'a document with no HTML title' do
    it 'falls back to the document id as the heading' do
      get solr_document_path(no_html_title_doc_id, format: :json)

      expect(response.parsed_body.dig('data', 'attributes', 'title')).to eq(no_html_title_doc_id)
    end
  end
end
