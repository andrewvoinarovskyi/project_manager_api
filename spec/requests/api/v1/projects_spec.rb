require 'rails_helper'

RSpec.describe "Projects API", type: :request do
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
  let!(:projects) { create_list(:project, 3, user: user) }
  let!(:other_project) { create(:project, user: other_user) }

  describe "GET /api/v1/projects" do
    it "returns only projects belonging to the current user" do
      get "/api/v1/projects", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json.size).to eq(projects.size)
      json.each do |proj|
        expect(proj["id"]).to be_present
        expect(projects.map(&:id)).to include(proj["id"])
      end
    end

    it "redirect if headers are missing" do
      get "/api/v1/projects"
      expect(response).to have_http_status(302)
    end
  end

  describe "GET /api/v1/projects/:id" do
    it "returns the project details for the current user" do
      project = projects.first
      get "/api/v1/projects/#{project.id}", headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["id"]).to eq(project.id)
    end

    it "does not allow accessing another user's project" do
      get "/api/v1/projects/#{other_project.id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/projects" do
    let(:valid_params) { { project: { title: "New Project", description: "Project description" } } }
    let(:invalid_params) { { project: { title: nil, description: "Missing title" } } }

    it "creates a new project with valid params" do
      post "/api/v1/projects", params: valid_params, headers: auth_headers
      expect(response).to have_http_status(:created)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("New Project")
      expect(json["id"]).to be_present
    end

    it "returns an error with invalid params" do
      post "/api/v1/projects", params: invalid_params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end
  end

  describe "PUT /api/v1/projects/:id" do
    let(:project) { projects.first }
    let(:update_params) { { project: { title: "Updated Title" } } }
    let(:invalid_update_params) { { project: { title: nil } } }

    it "updates the project with valid data" do
      put "/api/v1/projects/#{project.id}", params: update_params, headers: auth_headers
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["title"]).to eq("Updated Title")
    end

    it "returns an error when updating with invalid data" do
      put "/api/v1/projects/#{project.id}", params: invalid_update_params, headers: auth_headers
      expect(response).to have_http_status(:unprocessable_entity)
      json = JSON.parse(response.body)
      expect(json["errors"]).to be_present
    end

    it "does not allow updating another user's project" do
      put "/api/v1/projects/#{other_project.id}", params: update_params, headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "DELETE /api/v1/projects/:id" do
    it "deletes the project for the current user" do
      project = projects.first
      delete "/api/v1/projects/#{project.id}", headers: auth_headers
      expect(response).to have_http_status(:no_content)
      expect { project.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it "does not allow deleting another user's project" do
      delete "/api/v1/projects/#{other_project.id}", headers: auth_headers
      expect(response).to have_http_status(:not_found)
    end
  end
end
