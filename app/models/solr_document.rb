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

  # Creators and other contributors, merged and de-duplicated by name and identifiers.
  def contributors
    @contributors ||= (creator_structs + contributor_structs).uniq do |contributor|
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
    struct_field(:creators_struct_ss).each { |creator| creator['role'] = 'Creator' }
  end

  def contributor_structs
    struct_field(:contributors_struct_ss)
  end
end
