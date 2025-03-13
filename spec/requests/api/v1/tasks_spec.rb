require 'rails_helper'

RSpec.describe "Tasks API", type: :request do
  let(:user) { create(:user, password: 'password123') }
  let(:other_user) { create(:user, password: 'password123') }
  let(:auth_headers) do
    {
      'X-User-Email' => user.email,
      'X-User-Token' => user.authentication_token
    }
  end
  let(:other_auth_headers) do
    {
      'X-User-Email' => other_user.email,
      'X-User-Token' => other_user.authentication_token
    }
  end
  let!(:project) { create(:project, user: user) }
  let!(:other_project) { create(:project, user: other_user) }
  let!(:task1) { create(:task, project: project, status: "new", title: "Task 1") }
  let!(:task2) { create(:task, project: project, status: "in_progress", title: "Task 2") }
  let!(:other_task) { create(:task, project: other_project, status: "new", title: "Other Task") }

  describe "GET /api/v1/tasks" do
    it "returns only tasks belonging to the current user's projects" do
      get "/api/v1/tasks", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)

      expect(json.size).to eq(2)
      json_ids = json.map { |t| t["id"] }
      expect(json_ids).to include(task1.id, task2.id)
      expect(json_ids).not_to include(other_task.id)
    end

    it "filters tasks by status" do
      get "/api/v1/tasks", params: { status: "pending" }, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.all? { |t| t["status"] == "pending" }).to be_truthy
    end
  end

  describe "POST /api/v1/projects/:project_id/tasks" do
    let(:valid_params) { { task: { title: "New Task", description: "Task description", status: "new" } } }
    let(:invalid_params) { { task: { title: nil, description: "Missing title", status: "new" } } }

    it "creates a new task for the user's project" do
      post "/api/v1/projects/#{project.id}/tasks", params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("New Task")

      expect(json["id"]).to be_present
    end

    it "returns an error with invalid task data" do
      post "/api/v1/projects/#{project.id}/tasks", params: invalid_params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end

    it "does not allow creating a task for a project that does not belong to the user" do
      post "/api/v1/projects/#{other_project.id}/tasks", params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PUT /api/v1/tasks/:id" do
    let(:update_params) { { task: { title: "Updated Task Title" } } }
    let(:invalid_update_params) { { task: { title: nil } } }

    it "updates a task for a project belonging to the current user" do
      put "/api/v1/tasks/#{task1.id}", params: update_params, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Updated Task Title")
    end

    it "returns an error when updating with invalid data" do
      put "/api/v1/tasks/#{task1.id}", params: invalid_update_params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end

    it "does not allow updating a task that does not belong to the user" do
      put "/api/v1/tasks/#{other_task.id}", params: update_params, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/tasks/:id" do
    it "deletes a task belonging to the current user" do
      delete "/api/v1/tasks/#{task1.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)
      expect { task1.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not allow deleting a task that belongs to another user" do
      delete "/api/v1/tasks/#{other_task.id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
