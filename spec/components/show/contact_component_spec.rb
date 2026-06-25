# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::ContactComponent, type: :component do
  subject(:component) { described_class.new(document:) }

  let(:document) { SolrDocument.new(access_contact_struct_ss: contacts.to_json) }

  before { render_inline(component) }

  context 'with a contact that has a name and email' do
    let(:contacts) { [{ 'name' => 'Jane Doe', 'email' => 'jane@example.com' }] }

    it 'renders the section heading' do
      expect(page).to have_css('h2', text: 'Contact information')
    end

    it 'renders the contact name' do
      expect(page).to have_css('h3', text: 'Jane Doe')
    end

    it 'renders the email as a mailto link' do
      expect(page).to have_link('jane@example.com', href: 'mailto:jane@example.com')
    end
  end

  context 'with multiple contacts' do
    let(:contacts) do
      [{ 'name' => 'Jane Doe', 'email' => 'jane@example.com' },
       { 'name' => 'John Roe', 'email' => 'john@example.com' }]
    end

    it 'renders a mailto link for each' do
      expect(page).to have_link('jane@example.com', href: 'mailto:jane@example.com')
      expect(page).to have_link('john@example.com', href: 'mailto:john@example.com')
    end
  end
end
