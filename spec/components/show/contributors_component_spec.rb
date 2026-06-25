# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::ContributorsComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) do
    SolrDocument.new(
      id: 'abc-123',
      creators_struct_ss: creators.to_json,
      contributors_struct_ss: contributors.to_json
    )
  end
  let(:creators) { [] }
  let(:contributors) { [] }

  # Affiliation country rendering reaches out to the ROR API; stub it out.
  before { allow(RorService).to receive(:get_by_id).and_return(nil) }

  context 'when there are no creators or contributors' do
    it 'renders nothing' do
      render_inline(component)
      expect(page).to have_no_css('#contributors')
    end
  end

  context 'when creators and contributors are present' do
    let(:creators) do
      [{ 'name' => 'Alexandra Trelle',
         'name_identifiers' => [{ 'name_identifier' => '0000-0003-2837-8753',
                                  'name_identifier_scheme' => 'ORCID' },
                                { 'name_identifier' => '12345',
                                  'name_identifier_scheme' => 'CAP' }],
         'affiliation' => [{ 'name' => 'Stanford University',
                             'affiliation_identifier' => 'https://ror.org/00f54p054',
                             'affiliation_identifier_scheme' => 'ROR' }] }]
    end
    let(:contributors) { [{ 'name' => 'Jane Doe', 'name_identifiers' => [] }] }

    before { render_inline(component) }

    it 'renders the section heading' do
      expect(page).to have_css('#contributors h2', text: 'Contributors')
    end

    it 'renders an expand-items entry per contributor' do
      expect(page).to have_css("#contributors ul li[data-expand-items-target='item']", count: 2)
    end

    it 'sets the expand-items controller to show a fixed number of rows' do
      expect(page).to have_css(
        "div[data-controller='expand-items'][data-expand-items-max-rows-value='#{described_class::VISIBLE_COUNT}']"
      )
    end

    it 'renders a toggle with show more/less controls, hidden until JS reveals it' do
      expect(page).to have_css(
        "button[data-expand-items-target='toggle'][data-action='expand-items#toggle'][hidden]", visible: :all
      )
      expect(page).to have_css("[data-expand-items-target='moreControl']", text: 'Show more', visible: :all)
      expect(page).to have_css("[data-expand-items-target='lessControl']", text: 'Show less', visible: :all)
    end

    it 'links each contributor name to its detail modal, scoped to this dataset' do
      expect(page).to have_link('Alexandra Trelle',
                                href: %r{/catalog/contributor\?.*contributors_ssim.*Alexandra\+Trelle&id=abc-123})
      expect(page).to have_link('Jane Doe',
                                href: %r{/catalog/contributor\?.*contributors_ssim.*Jane\+Doe&id=abc-123})
    end

    it 'opens each contributor name as a modal trigger' do
      expect(page).to have_css('a[data-blacklight-modal="trigger"]', count: 2)
    end

    it 'renders an ORCID link for contributors with an ORCID identifier' do
      expect(page).to have_link(href: 'https://orcid.org/0000-0003-2837-8753')
    end

    it 'renders a Stanford profile link for contributors with a CAP identifier' do
      expect(page).to have_link(href: 'https://profiles.stanford.edu/intranet/12345')
    end

    it 'renders the affiliations in a styled, numbered block' do
      expect(page).to have_css('#contributors ol.bg-light li', count: 1)
      expect(page).to have_css('#contributors ol.bg-light li', text: 'Stanford University')
      expect(page).to have_css('#contributors ol.bg-light li sup', text: '1')
    end

    it 'references a contributor to its affiliation with a superscript number' do
      expect(page).to have_css('#contributors ul li', text: 'Alexandra Trelle') do |item|
        expect(item).to have_css('sup', text: '1')
      end
    end

    it 'links the affiliation to its ROR record' do
      expect(page).to have_link(href: 'https://ror.org/00f54p054')
    end
  end

  context 'when several contributors share an affiliation' do
    let(:creators) do
      [{ 'name' => 'Alexandra Trelle', 'name_identifiers' => [],
         'affiliation' => [stanford] }]
    end
    let(:contributors) do
      [{ 'name' => 'Jane Doe', 'name_identifiers' => [],
         'affiliation' => [stanford] }]
    end
    let(:stanford) do
      { 'name' => 'Stanford University',
        'affiliation_identifier' => 'https://ror.org/00f54p054',
        'affiliation_identifier_scheme' => 'ROR' }
    end

    before { render_inline(component) }

    it 'lists the shared affiliation once' do
      expect(page).to have_css('#contributors ol.bg-light li', count: 1)
    end

    it 'references the shared affiliation number from each contributor' do
      expect(page).to have_css('#contributors ul li', count: 2)
      expect(page).to have_css('#contributors ul li sup', text: '1', count: 2)
    end
  end

  context 'when an affiliation has ROR location data' do
    let(:creators) do
      [{ 'name' => 'Alexandra Trelle', 'name_identifiers' => [],
         'affiliation' => [{ 'name' => 'Stanford University',
                             'affiliation_identifier' => 'https://ror.org/00f54p054',
                             'affiliation_identifier_scheme' => 'ROR' }] }]
    end
    let(:org) { instance_double(RorService::Org, country_name: 'United States') }

    before do
      allow(RorService).to receive(:get_by_id).with('https://ror.org/00f54p054').and_return(org)
      render_inline(component)
    end

    it 'shows the affiliation country alongside the institution' do
      expect(page).to have_css('#contributors ol.bg-light li', text: 'United States')
    end
  end

  context 'when a creator and a contributor share a name and identifiers' do
    let(:creators) { [{ 'name' => 'Sam Smith', 'name_identifiers' => [] }] }
    let(:contributors) { [{ 'name' => 'Sam Smith', 'name_identifiers' => [] }] }

    it 'de-duplicates them into a single contributor' do
      render_inline(component)
      expect(page).to have_css('#contributors ul li', count: 1)
    end
  end
end
