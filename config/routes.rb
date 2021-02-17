Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  #resources :projects
  devise_for :users, 
  	:controllers => { :omniauth_callbacks => "callbacks", sessions: "sessions" }
  root 'front_page#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope '/api' do
  	resources :projects, except: [:new, :edit], defaults: {format: :json} do
  		resources :sprints
  		resources :issues
      resources :epics
      get 'activity', defaults: {format: :json}, to: 'projects#activity'
      get 'all_issues', defaults: {format: :json}, to: 'issues#all_issues'
      patch 'reorder_epics', defaults: {format: :json}, to: 'projects#reorder_epics'
      patch 'reorder_issues', defaults: {format: :json}, to: 'projects#reorder_issues'
  	end
    resources :sprints, defaults: {format: :json} do
      resources :issues
      patch 'reorder_issues', defaults: {format: :json}, to: 'sprints#reorder_issues'
      patch 'remove_issue', defaults: {format: :json}, to: 'sprints#remove_issue'
      post 'start', defaults: {format: :json}, to: 'sprints#start'
      post 'suspend', defaults: {format: :json}, to: 'sprints#suspend'
      post 'finish', defaults: {format: :json}, to: 'sprints#finish'
    end
    resources :issues, defaults: {format: :json} do
      resources :tasks
      patch 'reorder_tasks', defaults: {format: :json}, to: 'issues#reorder_tasks'
    end
    # patch 'issues/:id', to: 'issues#update'
    # delete 'issues/:id', to: 'issues#destroy'
    patch 'transfer_issues', to: 'transfer#transfer_issues'
    resources :tasks, defaults: {format: :json} do
      patch 'set_complete', defaults: {format: :json}, to: 'tasks#set_complete'
    end
    resources :epics, defaults: {format: :json} do
      resources :issues
      patch 'remove_issue', defaults: {format: :json}, to: 'epics#remove_issue'
      patch 'add_issue', defaults: {format: :json}, to: 'epics#add_issue'
      patch 'reorder_issues', defaults: {format: :json}, to: 'epics#reorder_issues'
    end
    delete 'tasks/:id', to: 'tasks#destroy'
  	resources :users, defaults: {format: :json}
  	get 'me', to: 'users#me'
    get 'user_profile', to: 'users#profile'
  end

  mount ActionCable.server => '/cable'
end
