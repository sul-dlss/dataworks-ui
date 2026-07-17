# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::AboutDatasetComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(
      id: 'abc-123',
      access_ssi: 'public',
      url_ss: 'https://example.com/datasets/abc-123',
      publication_year_isi: 2023,
      version_ss: '1.0',
      sizes_ssm: ['1.2 MB', '3 pages'],
      formats_ssim: ['PDF'],
      doi_ssi: '10.1234/5678'
    )
  end

  before { render_inline(component) }

  it 'renders the heading' do
    expect(page).to have_css('h2', text: 'About this dataset')
  end

  it 'renders the access badge alongside the heading' do
    expect(page).to have_css('h2 a.badge.access-badge.public', text: 'Public')
  end

  it 'shows where the dataset is available, using the URL host' do
    expect(page).to have_text('Available on example.com')
  end

  it 'renders the publication year and version' do
    expect(page).to have_text('Published: 2023')
    expect(page).to have_text('Version: 1.0')
  end

  it 'keeps each size/formats/DOI label glued to its value' do
    expect(rendered_content).to include('Size:</span>&nbsp;1.2 MB, 3 pages')
    expect(rendered_content).to include('Formats:</span>&nbsp;PDF')
    expect(rendered_content).to include('DOI:</span>&nbsp;10.1234/5678')
  end

  it 'links to the dataset in a new tab' do
    expect(page).to have_link('Access data', href: 'https://example.com/datasets/abc-123')
    expect(page).to have_css('a[target="_blank"][rel="noopener"]', text: 'Access data')
  end

  context 'when optional metadata is missing' do
    let(:document) do
      SolrDocument.new(id: 'abc-123', access_ssi: 'public', url_ss: 'https://example.com')
    end

    it 'omits the published, version, size, formats, and DOI labels' do
      expect(page).to have_no_text('Published:')
      expect(page).to have_no_text('Version:')
      expect(page).to have_no_text('Size:')
      expect(page).to have_no_text('Formats:')
      expect(page).to have_no_text('DOI:')
    end
  end

  context 'when the URL is not a parseable URI' do
    let(:document) do
      SolrDocument.new(id: 'abc-123', access_ssi: 'public', url_ss: 'not a url')
    end

    it 'falls back to showing the raw URL value' do
      expect(page).to have_text('Available on not a url')
    end
  end

  context 'when the document has no URL' do
    let(:document) { SolrDocument.new(id: 'abc-123', access_ssi: 'public') }

    it 'renders without the access button or "available on" line' do
      expect(page).to have_no_link('Access data')
      expect(page).to have_no_text('Available on')
      expect(page).to have_css('h2', text: 'About this dataset')
    end
  end
end
