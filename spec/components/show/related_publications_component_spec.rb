# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::RelatedPublicationsComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) { SolrDocument.new(related_identifiers_struct_ss: related_items.to_json) }

  before { render_inline(component) }

  context 'with a mix of publications and non-publications' do
    let(:related_items) do
      [
        # publication, grouped under "Cited by"
        { 'relation_type' => 'IsCitedBy', 'related_identifier_type' => 'DOI',
          'related_identifier' => '10.123/abc', 'resource_type_general' => 'JournalArticle' },
        # ISSN is always labelled "Journals"
        { 'relation_type' => 'References', 'related_identifier_type' => 'ISSN',
          'related_identifier' => '1234-5678', 'resource_type_general' => 'Text' },
        # second "Cited by" item, with a PMID id whose trailing .0 is stripped
        { 'relation_type' => 'IsCitedBy', 'related_identifier_type' => 'PMID',
          'related_identifier' => '98765.0', 'resource_type_general' => 'JournalArticle' },
        # excluded: non-publication resource type
        { 'relation_type' => 'Cites', 'related_identifier_type' => 'DOI',
          'related_identifier' => '10.999/data', 'resource_type_general' => 'Dataset' },
        # excluded: non-publication relation type
        { 'relation_type' => 'IsVersionOf', 'related_identifier_type' => 'DOI',
          'related_identifier' => '10.999/ver', 'resource_type_general' => 'Text' }
      ]
    end

    it 'renders the section heading' do
      expect(page).to have_css('h2', text: 'Related works')
    end

    it 'groups included publications under their relationship label' do
      expect(page).to have_css('h3', text: 'Cited by')
      expect(page).to have_css('h3', text: 'Journals')
    end

    it 'renders only the publications, excluding non-publication types and relations' do
      expect(page).to have_css("div[data-related-publications-target='publication']", count: 3)
    end

    it 'renders each publication with its id and id-type for the JS controller' do
      expect(page).to have_css(
        "div[data-related-publications-target='publication'][api-id='10.123/abc'][api-id-type='DOI']",
        text: 'DOI 10.123/abc'
      )
    end

    it 'strips the trailing .0 from PMID identifiers' do
      expect(page).to have_css(
        "div[data-related-publications-target='publication'][api-id='98765'][api-id-type='PMID']",
        text: 'PMID 98765'
      )
    end

    it 'exposes the OpenAlex info endpoint to the JS controller' do
      expect(page).to have_css(
        "div[data-controller='related-publications'][data-related-publications-url-value$='openalex_info']"
      )
    end
  end

  context 'with relationship types that map to display labels' do
    let(:related_items) do
      [
        { 'relation_type' => '', 'resource_type_general' => 'Text' },
        { 'relation_type' => 'IsDescribedBy', 'resource_type_general' => 'Text' },
        { 'relation_type' => 'Cites', 'resource_type_general' => 'Text' },
        { 'relation_type' => 'References', 'resource_type_general' => 'Text' },
        { 'relation_type' => 'IsSupplementedBy', 'resource_type_general' => 'Text' }
      ]
    end

    it 'labels each relationship type' do
      expect(page).to have_css('h3', text: 'Publication')
      expect(page).to have_css('h3', text: 'Described by')
      expect(page).to have_css('h3', text: 'Cites')
      expect(page).to have_css('h3', text: 'Reference')
      expect(page).to have_css('h3', text: 'Related resource')
    end
  end
end
