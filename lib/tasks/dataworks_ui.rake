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

  desc 'Prune saved search data older than the given number of days'
  task :prune_search_data, %i[days_old] => :environment do |_, args|
    days_old = args[:days_old].to_i
    raise ArgumentError, 'days_old is expected to be greater than 0' if days_old <= 0

    updated_at = Search.arel_table[:updated_at]
    Search.where(updated_at.lt(days_old.days.ago)).in_batches do |searches|
      searches.delete_all
      sleep(10) # Throttle the delete queries to avoid overloading the database
    end
  end
end
