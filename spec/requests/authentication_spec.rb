require "rails_helper"

RSpec.describe "Authentication", type: :request do
  describe "require_authentication concern" do
    it "is included in ApplicationController" do
      expect(ApplicationController.ancestors).to include(Authentication)
    end
  end

  describe "GET /up" do
    it "returns 200 without authentication" do
      get rails_health_check_path
      expect(response).to have_http_status(:ok)
    end
  end
end
