# frozen_string_literal: true

# Represents a single document returned from Solr
class SolrDocument
  include Blacklight::Solr::Document

  attribute :access, :string, 'access_ssi'
  attribute :description, :string, 'descriptions_tsim'
  attribute :doi, :string, 'doi_ssi'
  attribute :formats, :array, 'formats_ssim'
  attribute :publication_year, :string, 'publication_year_isi'
  attribute :sizes, :array, 'sizes_ssm'
  attribute :stanford_authored?, :boolean, 'stanford_contributor_bsi'
  attribute :subjects, :array, 'subjects_ssim'
  attribute :url, :string, 'url_ss'
  attribute :version, :string, 'version_ss'

  # The host portion of the dataset's external URL, for "Available on <host>" labels.
  def url_host
    return if url.blank?

    URI.parse(url).host
  rescue URI::InvalidURIError
    url
  end

  # Parse a JSON `*_struct_ss` field into Ruby data, defaulting to an empty array when blank.
  def struct_field(key)
    JSON.parse(self[key] || '[]')
  end

  # self.unique_key = 'id'

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Document::SemanticFields#field_semantics
  # and Blacklight::Document::SemanticFields#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension(Blacklight::Document::DublinCore)
end
