# frozen_string_literal: true

# Use this file to define cron jobs, managed by the `whenever` gem and deployed
# via Capistrano. Run `bundle exec whenever` to preview the generated crontab.
#
# Learn more: http://github.com/javan/whenever

set :output, 'log/cron.log'

# Prune anonymous saved-search data so the `searches` table stays tidy.
every :day, at: '4:00 am' do
  rake 'dataworks_ui:prune_search_data[30]'
end
