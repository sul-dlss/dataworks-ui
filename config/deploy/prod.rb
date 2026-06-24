# frozen_string_literal: true

server 'dataworks-ui-prod.stanford.edu', user: 'dataworks-ui', roles: %w[web db app worker]

Capistrano::OneTimeKey.generate_one_time_key!
set :rails_env, 'production'

