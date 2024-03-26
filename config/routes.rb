Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  #resources :projects
  devise_for :users, 
  	:controllers => { :omniauth_callbacks => "callbacks", sessions: "sessions" }
  root 'front_page#show'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  scope '/api' do
    post 'projects', defaults: {format: :json}, to: 'projects#create'
    post 'projects/join', defaults: {format: :json}, to: 'projects#join_project'
  	resources :projects, except: [:new, :edit], defaults: {format: :json} do
  		resources :sprints
  		resources :issues
      resources :epics
      resources :comments
      get 'activity', defaults: {format: :json}, to: 'projects#activity'
      get 'all_issues', defaults: {format: :json}, to: 'issues#all_issues'
      patch 'reorder_epics', defaults: {format: :json}, to: 'projects#reorder_epics'
      patch 'reorder_issues', defaults: {format: :json}, to: 'projects#reorder_issues'
      get 'team', defaults: {format: :json}, to: 'projects#team'
      post 'add_member', defaults: { format: :json }, to: 'projects.add_member'
      post 'remove_member', defaults: { format: :json }, to: 'projects.remove_member'
  	end
    resources :sprints, defaults: {format: :json} do
      resources :issues
      resources :comments
      patch 'reorder_issues', defaults: {format: :json}, to: 'sprints#reorder_issues'
      patch 'remove_issue', defaults: {format: :json}, to: 'sprints#remove_issue'
      patch 'add_issue', defaults: {format: :json}, to: 'sprints#add_issue'
      post 'start', defaults: {format: :json}, to: 'sprints#start'
      post 'suspend', defaults: {format: :json}, to: 'sprints#suspend'
      post 'finish', defaults: {format: :json}, to: 'sprints#finish'
      get 'team_summary', defaults: {format: :json}, to: 'sprints#team_summary'
      get 'retrospective_report', defaults: {format: :json}, to: 'sprints#retrospective_report'
      get 'snapshot', defaults: {format: :json}, to: 'sprints#snapshot'
      get 'compare', defaults: { format: :json }, to: 'sprints#compare'
      get 'teacher_report', defaults: { format: :json }, to: 'sprints#teacher_report'
    end
    resources :issues, defaults: {format: :json} do
      resources :tasks
      resources :comments
      patch 'reorder_tasks', defaults: {format: :json}, to: 'issues#reorder_tasks'
      patch 'assign_issue', defaults: {format: :json}, to: 'issues#assign_issue'
      patch 'mark_complete', defaults: {format: :json}, to: 'issues#mark_complete'
      patch 'move_to_backlog', defaults: {format: :json}, to: 'issues#move_to_backlog'
      patch 'move_to_sprint/:sprint_id', defaults: {format: :json}, to: 'issues#move_to_sprint'
      post 'add_acceptance_criterion', defaults: {format: :json}, to: 'issues#add_acceptance_criterion'
      delete 'remove_acceptance_criterion/:ac_id', defaults: {format: :json}, to: 'issues#remove_acceptance_criterion', as: 'remove_acceptance_criterion'
      patch 'set_ac_completed/:ac_id', defaults: {format: :json}, to: 'issues#set_ac_completed', as: 'set_ac_completed'
      patch 'acceptance_criterion/:ac_id', defaults: {format: :json}, to: 'issues#update_ac', as: 'update_ac'
    end
    # patch 'issues/:id', to: 'issues#update'
    # delete 'issues/:id', to: 'issues#destroy'
    patch 'transfer_issues', to: 'transfer#transfer_issues'
    resources :tasks, defaults: {format: :json} do
      patch 'set_complete', defaults: {format: :json}, to: 'tasks#set_complete'
      patch 'assign_task', defaults: {format: :json}, to: 'tasks#assign_task'
    end
    resources :epics, defaults: {format: :json} do
      resources :issues
      resources :comments
      patch 'remove_issue', defaults: {format: :json}, to: 'epics#remove_issue'
      patch 'add_issue', defaults: {format: :json}, to: 'epics#add_issue'
      patch 'reorder_issues', defaults: {format: :json}, to: 'epics#reorder_issues'
    end
    delete 'tasks/:id', to: 'tasks#destroy'
  	resources :users, defaults: {format: :json}
  	get 'me', to: 'users#me'
    get 'user_profile', to: 'users#profile'
    resources :comments, defaults: {format: :json}

    get 'news', to: 'news#news', defaults: {format: :json}
    post 'news/readAll', to: 'news#readAll'
  end

  mount ActionCable.server => '/cable'
end
