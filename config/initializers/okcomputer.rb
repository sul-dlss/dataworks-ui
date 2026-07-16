# frozen_string_literal: true

require 'okcomputer'

# /status for 'upness', e.g. for a load balancer
# /status/all to show all dependencies
# /status/<name-of-check> for a specific check
OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true

# OkComputer registers two checks by default:
#   'default'  -> the app booted and is serving requests
#   'database' -> ActiveRecord can reach the database
# We add the Ruby version and a Solr ping below.

OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new

solr_url = Blacklight.blacklight_yml[Rails.env]['url']
OkComputer::Registry.register 'solr', OkComputer::HttpCheck.new("#{solr_url}/admin/ping")
