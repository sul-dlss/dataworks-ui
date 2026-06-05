# frozen_string_literal: true

require_relative 'solr_task_helpers'

namespace :dataworks_ui do
  namespace :index do
    desc 'Index the test fixtures into Solr'
    task seed: :environment do
      puts 'Indexing test fixtures'

      fixtures_path = Rails.root.join('spec/fixtures/solr_documents/*.json').to_s
      docs = Dir[fixtures_path].flat_map { |f| JSON.parse(File.read(f)) }

      Blacklight.default_index.connection.add docs
      Blacklight.default_index.connection.commit
    end
  end
end
