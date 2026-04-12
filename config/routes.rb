Rails.application.routes.draw do
  namespace :api do
    resources :todo_lists, only: %i[index], path: :todolists do
      resources :todo_items, only: %i[index create show update destroy], path: :todoitems do
        post 'complete_all', on: :collection
      end
    end
  end

  resources :todo_lists, only: %i[index new create show edit update destroy], path: :todolists do
    resources :todo_items, only: %i[new create edit update destroy], path: :todoitems
  end
end