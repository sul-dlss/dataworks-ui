# frozen_string_literal: true

require 'open3'
require 'net/http'

def wait_for_solr(url, timeout: 60)
  uri = URI("#{url}/admin/ping")
  deadline = Time.now.to_i + timeout
  loop do
    response = Net::HTTP.get_response(uri)
    raise "Unexpected status #{response.code}" unless response.code == '200'

    puts 'Solr is ready' # rubocop:disable Rails/Output
    return
  rescue StandardError
    raise "Solr did not become ready within #{timeout}s" if Time.now.to_i > deadline

    sleep 2
  end
end

# rubocop:disable Rails/Output
def system_with_error_handling(*args)
  Open3.popen3(*args) do |_stdin, stdout, stderr, thread|
    puts stdout.read
    raise "Unable to run #{args.inspect}: #{stderr.read}" unless thread.value.success?
  end
end

def with_solr(&)
  # We're being invoked by the app entrypoint script and solr is already up via docker compose
  if ENV['SOLR_ENV'] == 'docker-compose'
    yield
  elsif system('docker compose version')
    # We're not running `docker compose up' but still want to use a docker instance of solr.
    begin
      puts 'Starting Solr'
      system_with_error_handling 'docker compose up -d solr'
      wait_for_solr(ENV.fetch('SOLR_URL', 'http://127.0.0.1:8983/solr/blacklight-core'))
      yield
    ensure
      puts 'Stopping Solr'
      system_with_error_handling 'docker compose stop solr'
    end
  else
    SolrWrapper.wrap do |solr|
      solr.with_collection(&)
    end
  end
  # rubocop:enable Rails/Output
end
