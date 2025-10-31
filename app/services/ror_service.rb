# frozen_string_literal: true

# Class for ROR support
class RorService
  def self.get_by_id(ror_id)
    new.get_by_id(ror_id)
  end

  attr_reader :conn

  def initialize
    @conn = new_conn
  end

  # Fetch a single organization by ROR ID and cache the result
  def get_by_id(ror_id)
    Rails.cache.fetch("ror_org_#{ror_id}", expires_in: 30.days) do
      organization(ror_id)
    end
  end

  private

  def organization(ror_id)
    result = conn.get("/v2/organizations/#{ror_id}", {}, headers).body
    Org.new(result.slice('id', 'names', 'locations', 'types')) if result
  rescue Faraday::ResourceNotFound
    nil
  end

  def new_conn
    Faraday.new({ url: Settings.ror.url }) do |f|
      f.request :json
      f.response :json
      f.response :raise_error
    end
  end

  def headers
    {
      'Accept' => 'application/json',
      'User-Agent' => 'Stanford DataWorks'
    }
  end

  # Data model for a RoR organization
  class Org
    attr_accessor :id

    def initialize(data)
      @data = data
      @id = data['id']
    end

    def name
      names.find { |n| n['types'].include?('ror_display') }&.dig('value')
    end

    def website_url
      links.find { |l| l['type'] == 'website' }&.dig('value')
    end

    def country_code
      geonames_details.pick('country_code')
    end

    def country_name
      geonames_details.pick('country_name')
    end

    def country_emoji
      country_code.upcase.chars.map { |char| 0x1F1E6 + char.ord - 'A'.ord }.pack('U*') if country_code
    end

    private

    def names
      @names ||= Array(@data['names'])
    end

    def links
      @links ||= Array(@data['links'])
    end

    def geonames_details
      @geonames_details ||= Array(@data['locations']).pluck('geonames_details')
    end
  end
end
