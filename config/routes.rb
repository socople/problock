# rubocop:disable BlockLength
Rails.application.routes.draw do
  mount Ckeditor::Engine => '/ckeditor'
  #
  devise_for :admins, controllers: { sessions: 'admins/sessions' }

  %w[404 422 500 503].each do |code|
    get code, to: 'errors#show', code: code
  end

  root to: 'home#index'
  resources :projects,   only: %i[index]
  resources :categories, only: %i[show]
  resources :contacts,   only: %i[new create]

  resources :quotations, except: %i[destroy] do
    patch :confirm,   on: :member
    get   :confirmed, on: :member
  end

  resources :pages, only: [] do
    get 'quienes-somos', action: 'about', as: :about, on: :collection
  end

  namespace :latte do
    root to: 'activity_logs#index'

    resources :activity_logs, only: %i[index show]
    resources :profile,       only: %i[edit update]
    resources :versions,      only: %i[show]
    resources :tags,          only: %i[index]

    resources :settings, only: %i[update] do
      get :edit, on: :collection
    end

    resources :admin_settings, only: [] do
      put :table_columns, on: :collection
    end

    resources :habtm, only: [] do
      get :available, on: :collection
      get :enabled, on: :collection
    end

    resources :recycler_docks, only: %i[index show] do
      get :restore, on: :member
    end

    resources :images, only: %i[create update destroy] do
      get ':imageable_type/:imageable_id/',
          to: 'images#list',
          as: :list,
          on: :collection

      put :sort, as: :sort, on: :collection
    end

    resources :attachments, only: %i[create update destroy] do
      get ':attachable_type/:attachable_id/',
          to: 'attachments#list',
          as: :list,
          on: :collection

      put :sort, as: :sort, on: :collection
    end

    resources :external_videos, only: %i[create update destroy] do
      get ':external_videoable_type/:external_videoable_id/',
          to: 'external_videos#list',
          as: :list,
          on: :collection

      put :sort, as: :sort, on: :collection
    end

    %i[
      admins
      pages
      items
      categories
      products
      projects
      contacts
      quotation_categories
    ].each do |resource|
      resources resource do
        put :updates,  on: :collection
        put :destroys, on: :collection
        get :list,     on: :collection
      end
    end

    namespace :grid do
      %i[
        admins
      ].each do |resource|
        resources resource, only: %i[index new create]
      end
    end
  end
end
