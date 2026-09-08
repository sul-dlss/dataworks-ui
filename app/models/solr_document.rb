# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document

  attribute :access, :string, 'access_ssi'
  attribute :access_contact_struct, :json, 'access_contact_struct_ss', default: '[]'
  attribute :contributors_struct, :json, 'contributors_struct_ss', default: '[]'
  attribute :creators_struct, :json, 'creators_struct_ss', default: '[]'
  attribute :dates_struct, :json, 'dates_struct_ss', default: '[]'
  attribute :description_html, :string, 'descriptions_html_tsm'
  attribute :doi, :string, 'doi_ssi'
  attribute :formats, :array, 'formats_ssim'
  attribute :provider_identifier_map_struct, :json, 'provider_identifier_map_struct_ss', default: '{}'
  attribute :publication_year, :string, 'publication_year_isi'
  attribute :related_identifiers_struct, :json, 'related_identifiers_struct_ss', default: '[]'
  attribute :rights_list_struct, :json, 'rights_list_struct_ss', default: '[]'
  attribute :sizes, :array, 'sizes_ssm'
  attribute :stanford_authored?, :boolean, 'stanford_contributor_bsi'
  attribute :subjects, :array, 'subjects_ssim'
  attribute :url, :string, 'url_ss'
  attribute :version, :string, 'version_ss'

  # True when the publication year is in the future, indicating an embargoed dataset.
  # Only whole future years are treated as embargoed; dates later in the current year are not.
  def embargoed?
    return false if publication_year.blank?

    publication_year.to_i > Time.zone.today.year
  end

  # The host portion of the dataset's external URL, for "Available on <host>" labels.
  def url_host
    return if url.blank?

    URI.parse(url).host
  rescue URI::InvalidURIError
    url
  end

  # Creators and other contributors, merged and de-duplicated by name and identifiers.
  def contributors
    @contributors ||= (creator_structs + contributors_struct).uniq do |contributor|
      [contributor['name'], contributor['name_identifiers']]
    end
  end

  # Affiliations recorded for the named contributor on this dataset.
  def affiliations_for(name)
    contributors.select { |contributor| contributor['name'] == name }
                .flat_map { |contributor| Array(contributor['affiliation']) }
  end

  # self.unique_key = 'id'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)

  private

  # Creator structs, tagged with the "Creator" role they lack by default.
  def creator_structs
    creators_struct.each { |creator| creator['role'] = 'Creator' }
  end
end
