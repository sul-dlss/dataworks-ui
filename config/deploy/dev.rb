# frozen_string_literal: true

server 'sul-dwexp-test.stanford.edu', user: 'dwexp', roles: %w[web db app worker]
server 'dataworks-ui-dev.stanford.edu', user: 'dataworks-ui', roles: %w[web db app worker]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'
