# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_07_161018) do

  create_table "activities", force: :cascade do |t|
    t.integer "user_id"
    t.string "action"
    t.string "modifier"
    t.integer "project_id"
    t.integer "sprint_id"
    t.integer "issue_id"
    t.integer "task_id"
    t.integer "epic_id"
    t.integer "project_context_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "sprint2_id"
    t.integer "epic2_id"
    t.integer "user2_id"
    t.index ["epic2_id"], name: "index_activities_on_epic2_id"
    t.index ["epic_id"], name: "index_activities_on_epic_id"
    t.index ["issue_id"], name: "index_activities_on_issue_id"
    t.index ["project_context_id"], name: "index_activities_on_project_context_id"
    t.index ["project_id"], name: "index_activities_on_project_id"
    t.index ["sprint2_id"], name: "index_activities_on_sprint2_id"
    t.index ["sprint_id"], name: "index_activities_on_sprint_id"
    t.index ["task_id"], name: "index_activities_on_task_id"
    t.index ["user2_id"], name: "index_activities_on_user2_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "burndown_data", force: :cascade do |t|
    t.integer "day"
    t.integer "value"
    t.integer "sprint_id", null: false
    t.index ["sprint_id"], name: "index_burndown_data_on_sprint_id"
  end

  create_table "epics", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "size"
    t.integer "project_id"
    t.string "color"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "issue_order"
    t.index ["project_id"], name: "index_epics_on_project_id"
  end

  create_table "issues", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "estimate"
    t.string "state"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "last_changed_by_id"
    t.integer "sprint_id"
    t.string "task_order"
    t.integer "epic_id"
    t.integer "parent_id"
    t.integer "assignee_id"
    t.index ["assignee_id"], name: "index_issues_on_assignee_id"
    t.index ["epic_id"], name: "index_issues_on_epic_id"
    t.index ["last_changed_by_id"], name: "index_issues_on_last_changed_by_id"
    t.index ["parent_id"], name: "index_issues_on_parent_id"
    t.index ["project_id"], name: "index_issues_on_project_id"
    t.index ["sprint_id"], name: "index_issues_on_sprint_id"
  end

  create_table "project_permissions", force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "scope"
    t.index ["project_id"], name: "index_project_permissions_on_project_id"
    t.index ["user_id"], name: "index_project_permissions_on_user_id"
  end

  create_table "projects", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "owner_id"
    t.string "epic_order"
    t.string "issue_order"
    t.integer "current_sprint_id"
    t.boolean "demo"
    t.index ["current_sprint_id"], name: "index_projects_on_current_sprint_id"
    t.index ["owner_id"], name: "index_projects_on_owner_id"
  end

  create_table "sprints", force: :cascade do |t|
    t.string "title"
    t.string "description"
    t.integer "project_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "issue_order"
    t.boolean "started"
    t.boolean "completed"
    t.date "start_date"
    t.date "end_date"
    t.integer "starting_work"
    t.string "goal"
    t.date "actual_end_date"
    t.string "retrospective"
    t.index ["project_id"], name: "index_sprints_on_project_id"
  end

  create_table "tasks", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.integer "estimate"
    t.integer "issue_id"
    t.integer "last_changed_by_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "state"
    t.integer "assignee_id"
    t.index ["assignee_id"], name: "index_tasks_on_assignee_id"
    t.index ["issue_id"], name: "index_tasks_on_issue_id"
    t.index ["last_changed_by_id"], name: "index_tasks_on_last_changed_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "first_name"
    t.string "last_name"
    t.string "picture"
    t.string "permission_scope"
    t.string "displayName"
    t.string "oauthsub"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "activities", "projects", column: "project_context_id"
  add_foreign_key "activities", "users", column: "user2_id"
  add_foreign_key "burndown_data", "sprints"
  add_foreign_key "issues", "epics"
  add_foreign_key "issues", "issues", column: "parent_id"
  add_foreign_key "issues", "users", column: "assignee_id"
  add_foreign_key "issues", "users", column: "last_changed_by_id"
  add_foreign_key "projects", "sprints", column: "current_sprint_id"
  add_foreign_key "sprints", "projects"
  add_foreign_key "tasks", "users", column: "assignee_id"
  add_foreign_key "tasks", "users", column: "last_changed_by_id"
end
