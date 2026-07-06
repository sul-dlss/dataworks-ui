# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Show::RelatedDatesFieldComponent, type: :component do
  let(:view_context) { vc_test_controller.view_context }
  let(:document) { SolrDocument.new(dates_struct_ss: dates.to_json) }
  let(:field_config) { Blacklight::Configuration::ShowField.new(key: 'dates_struct_ss', label: 'Related dates') }
  let(:field) { Blacklight::FieldPresenter.new(view_context, document, field_config) }

  before { render_inline(described_class.new(field:, show: true)) }

  context 'with a mix of typed and untyped dates' do
    let(:dates) do
      [{ 'date' => '2023-01-01' },
       { 'date' => '2023-01-03', 'date_type' => 'Updated' },
       { 'date' => '2022-11-25', 'date_type' => 'Coverage' }]
    end

    it 'renders the field label' do
      expect(page).to have_css 'dt', text: 'Related dates'
    end

    it 'renders each typed date as its own value cell' do
      expect(page).to have_css 'dd', text: 'Updated: 2023-01-03'
      expect(page).to have_css 'dd', text: 'Coverage: 2022-11-25'
    end

    it 'renders one value cell per typed date' do
      expect(page).to have_css 'dd', count: 2
    end
  end
end
