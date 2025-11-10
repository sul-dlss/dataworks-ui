# frozen_string_literal: true

# Blacklight controller that handles searches and document requests
class CatalogController < ApplicationController

  include Blacklight::Catalog

  # If you'd like to handle errors returned by Solr in a certain way,
  # you can use Rails rescue_from with a method you define in this controller,
  # uncomment:
  #
  # rescue_from Blacklight::Exceptions::InvalidRequest, with: :my_handling_method

  configure_blacklight do |config|
    ## Specify the style of markup to be generated (may be 4 or 5)
    # config.bootstrap_version = 5
    #
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## The destination for the link around the logo in the header
    # config.logo_link = root_path
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      qt: 'search',
      rows: 10,
      spellcheck: false
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'
    #config.document_solr_path = 'get'

    # items to show per page, each number in the array represent another option to choose from.
    #config.per_page = [10,20,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'title_tsim'
    # config.index.display_type_field = 'format'
    # config.index.thumbnail_field = 'thumbnail_path_ss'

    # The presenter is the view-model class for the page
    # config.index.document_presenter_class = MyApp::IndexPresenter

    # Some components can be configured
    # config.index.document_component = MyApp::SearchResultComponent
    # config.index.constraints_component = MyApp::ConstraintsComponent
    # config.index.search_bar_component = MyApp::SearchBarComponent
    # config.index.search_header_component = MyApp::SearchHeaderComponent
    # config.index.document_actions.delete(:bookmark)
    config.header_component = Dwexp::HeaderComponent
    config.logo_link = 'https://library.stanford.edu'

    config.add_results_document_tool(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, component: Blacklight::Document::BookmarkComponent, if: :render_bookmarks_control?)
    config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    # config.show.title_field = 'title_tsim'
    # config.show.display_type_field = 'format'
    # config.show.thumbnail_field = 'thumbnail_path_ss'
    #
    # The presenter is a view-model class for the page
    # config.show.document_presenter_class = MyApp::ShowPresenter
    #
    # These components can be configured
    # config.show.document_component = MyApp::DocumentComponent
    # config.show.sidebar_component = MyApp::SidebarComponent
    # config.show.embed_component = MyApp::EmbedComponent

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    config.add_facet_field 'stanford_dataset_bsi', label: 'Stanford datasets', component: Dwexp::StanfordDatasetFacetComponent
    config.add_facet_field 'access_ssi', label: 'Access'
    config.add_facet_field 'provider_ssi', label: 'Provider', show: false
    # config.add_facet_field 'doi_ssi', label: 'DOI', limit: 15
    config.add_facet_field 'contributors_ssim', label: 'Contributors', limit: 15
    config.add_facet_field 'funders_ssim', label: 'Funders', limit: 15
    config.add_facet_field 'publisher_ssi', label: 'Publishers', limit: 15
    config.add_facet_field 'publication_year_isi', label: 'Publication year', limit: 15
    config.add_facet_field 'temporal_isim', label: 'Temporal Coverage', limit: 15
    config.add_facet_field 'subjects_ssim', label: 'Subjects', limit: 15
    # config.add_facet_field 'affiliation_names_sim', label: 'Affiliations', limit: 15
    config.add_facet_field 'language_ssi', label: 'Language', show: false
    config.add_facet_field 'formats_ssim', label: 'Formats', limit: 15
    config.add_facet_field 'department_ssim', label: 'Stanford department', limit: 15
    #config.add_facet_field 'creators_ids_sim', label: 'Creator Ids', limit: 15
    #config.add_facet_field 'contributors_ids_sim', label: 'Contributor Ids', limit: 15
    #config.add_facet_field 'funders_ids_sim', label: 'Funder Ids', limit: 15
    #config.add_facet_field 'publisher_id_sim', label: 'Publisher Ids', limit: 15
    #config.add_facet_field 'related_ids_sim', label: 'Related Ids', limit: 15
    #config.add_facet_field 'rights_uris_sim', label: 'Rights URIs', limit: 15
    #config.add_facet_field 'courses_sim', label: 'Courses'


    #config.add_facet_field 'example_pivot_field', label: 'Pivot Field', pivot: ['format', 'language_ssim'], collapsing: true

    # config.add_facet_field 'example_query_facet_field', label: 'Publish Date', :query => {
    #    :years_5 => { label: 'within 5 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 5 } TO *]" },
    #    :years_10 => { label: 'within 10 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 10 } TO *]" },
    #    :years_25 => { label: 'within 25 Years', fq: "pub_date_ssim:[#{Time.zone.now.year - 25 } TO *]" }
    # }


    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field 'title_tsim', label: 'Title'
    config.add_index_field 'version_ss', label: 'Version'
    config.add_index_field 'url_ss', label: 'Url', helper_method: :url_link
    config.add_index_field 'provider_ssi', label: 'Provider'
    config.add_index_field 'descriptions_tsim', label: 'Description', helper_method: :render_rich_text_preview
    config.add_index_field 'variables_tsim', label: 'Variables'

    # Show fields
    config.add_show_field 'title_tsim', label: 'Title'
    config.add_show_field 'subtitle_tsim', label: 'Subtitle'
    config.add_show_field 'alternative_title_tsim', label: 'Alternative Title'
    config.add_show_field 'translate_title_tsim', label: 'Translated Title'
    config.add_show_field 'other_title_tsim', label: 'Other Title'
    config.add_show_field 'contributors_ssim', label: 'Contributors', component: Dwexp::ContributorTableComponent
    config.add_show_field 'access_ssi', label: 'Access', link_to_facet: true
    config.add_show_field 'url_ss', label: 'URL', helper_method: :url_link
    config.add_show_field 'provider_ssi', label: 'Provider', link_to_facet: true
    config.add_show_field 'doi_ssi', label: 'DOI'
    config.add_show_field 'provider_identifier_ssi', label: 'Provider id'
    config.add_show_field 'descriptions_tsim', label: 'Description', helper_method: :render_rich_text
    config.add_show_field 'methods_tsim', label: 'Methods', helper_method: :render_rich_text
    config.add_show_field 'other_descriptions_tsim', label: 'Other description', helper_method: :render_rich_text
    config.add_show_field 'subjects_ssim', label: 'Subjects', helper_method: :display_facet_separate_lines
    config.add_show_field 'language_ssi', label: 'Language', link_to_facet: true
    config.add_show_field 'sizes_ssm', label: 'Sizes'
    config.add_show_field 'formats_ssim', label: 'Formats', link_to_facet: true
    config.add_show_field 'version_ss', label: 'Version'
    config.add_show_field 'funding_references_struct_ss', label: 'Funding Full Info', helper_method: :display_funding_information
    config.add_show_field 'publication_year_isi', label: 'Publication Year', link_to_facet: true
    config.add_show_field 'temporal_isim', label: 'Temporal Coverage', link_to_facet: true
    config.add_show_field 'geo_place_ssim', label: 'Geographic Coverage'
    config.add_show_field 'variables_tsim', label: 'Variables', helper_method: :display_variables
    config.add_show_field 'related_identifiers_struct_ss', label: 'Related Publications', component: Dwexp::RelatedPublicationsComponent
    config.add_show_field 'dates_struct_ss', label: 'Related Dates', helper_method: :display_dates
    config.add_show_field 'rights_list_struct_ss', label: 'Rights', helper_method: :display_rights
    config.add_show_field 'provider_identifier_map_struct_ss', label: 'Also Available At', helper_method: :display_also_available

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', label: 'All Fields'


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
      field.solr_parameters = {
        'spellcheck.dictionary': 'title',
        qf: '${title_qf}',
        pf: '${title_pf}'
      }
    end

    config.add_search_field('author') do |field|
      field.solr_parameters = {
        'spellcheck.dictionary': 'author',
        qf: '${author_qf}',
        pf: '${author_pf}'
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.solr_parameters = {
        'spellcheck.dictionary': 'subject',
        qf: '${subject_qf}',
        pf: '${subject_pf}'
    }
    end

    config.add_search_field('DOI') do |field|
      field.solr_parameters = {
        qf: 'doi_ssi'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the Solr field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case). Add the sort: option to configure a
    # custom Blacklight url parameter value separate from the Solr sort fields.
    #config.add_sort_field 'relevance', sort: 'score desc, pub_date_ssi desc, title_si asc', label: 'relevance'
    #config.add_sort_field 'year-desc', sort: 'pub_date_si desc, title_si asc', label: 'year'
    #config.add_sort_field 'author', sort: 'author_si asc, title_si asc', label: 'author'
    #config.add_sort_field 'title_si asc, pub_date_si desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggester
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrconfig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end
end
