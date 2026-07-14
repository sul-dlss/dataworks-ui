# frozen_string_literal: true

Rails.application.routes.draw do
  mount Blacklight::Engine => '/'
  root to: 'landing_page#index'
  concern :searchable, Blacklight::Routes::Searchable.new
  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new

  resource :catalog, only: [], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
    concerns :range_searchable
    get 'contributor', to: 'catalog#contributor', as: 'contributor'
    get 'facet_results/:id', to: 'catalog#facet_results', as: 'facet_results'
  end

  get 'openalex_info', to: 'related_publications#openalex_info', as: 'openalex_info'

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  resource :feedback_form, path: 'feedback', only: %i[new create]
  get 'feedback' => 'feedback_forms#new'

  get 'up' => 'rails/health#show', as: :rails_health_check

  post '/challenge', to: 'bot_challenge_page/bot_challenge_page#verify_challenge', as: :bot_detect_challenge
end
