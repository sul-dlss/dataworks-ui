# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require_relative 'config/application'

Rails.application.load_tasks

require 'solr_wrapper/rake_task' unless Rails.env.production?

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new
rescue LoadError
  task rubocop: [:environment] do
    raise 'Unable to load rubocop'
  end
end

require_relative 'lib/tasks/solr_task_helpers'

task(:default).clear

task default: :ci

task ci: %i[rubocop] do
  with_solr do
    # run the tests
    Rake::Task['dataworks_ui:index:seed'].invoke
    Rake::Task['spec'].invoke
  end
end
