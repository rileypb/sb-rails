RailsAdmin.config do |config|

  ### Popular gems integration

  config.parent_controller = 'AdminParentController'

  ## == Devise ==
  config.authenticate_with do
    warden.authenticate! scope: :user
  end
  config.current_user_method { current_user }

  ## == CancanCan ==
  config.authorize_with :cancancan

  ## == Pundit ==
  # config.authorize_with :pundit

  ## == PaperTrail ==
  # config.audit_with :paper_trail, 'User', 'PaperTrail::Version' # PaperTrail >= 3.0.0

  ### More at https://github.com/sferik/rails_admin/wiki/Base-configuration

  ## == Gravatar integration ==
  ## To disable Gravatar integration in Navigation Bar set to false
  # config.show_gravatar = true

  config.actions do
    dashboard                     # mandatory
    index                         # mandatory
    new
    export
    bulk_delete
    show
    edit
    delete
    show_in_app

    ## With an audit adapter, you can add:
    # history_index
    # history_show
  end

  config.model 'User' do 
    list do
      sort_by :id
      field :id do
        sort_reverse false
      end
      field :email
      field :first_name
      field :last_name
      field :picture
    end
    object_label_method do
      :label
    end
  end

  config.model 'ProjectPermission' do
    object_label_method do
      :label
    end
  end

  config.model 'IssueList' do
    object_label_method do
      :label
    end
  end

  config.model 'Project' do
    object_label_method do
      :label
    end
    list do
      field :name
      field :owner do
        searchable [:email, :name]
      end
      field :demo
      field :key
      field :hidden
      field :created_at
      field :updated_at
      field :picture
      field :setting_auto_close_issues
      field :setting_use_acceptance_criteria
      field :epic_order
      field :issue_order
      field :current_sprint
      field :project_permissions
      field :allow_issue_completion_without_sprint
      configure :created_at do
        read_only true
      end
      configure :updated_at do
        read_only true
      end
    end

  end

end
