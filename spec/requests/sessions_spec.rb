require "rails_helper"

RSpec.describe "Sessions", type: :request do
  let(:user) { create(:user, email_address: "test@example.com", password: "password123") }

  describe "GET /session/new" do
    it "returns 200" do
      get new_session_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /session" do
    it "redirects on valid credentials" do
      post session_path, params: { user: { email_address: user.email_address, password: "password123" } }
      expect(response).to redirect_to(root_path)
    end

    it "creates a session on valid credentials" do
      expect {
        post session_path, params: { user: { email_address: user.email_address, password: "password123" } }
      }.to change(Session, :count).by(1)
    end

    it "shows alert on wrong password" do
      post session_path, params: { user: { email_address: user.email_address, password: "wrong" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Неверный email или пароль")
    end

    it "does not create a session on wrong password" do
      expect {
        post session_path, params: { user: { email_address: user.email_address, password: "wrong" } }
      }.not_to change(Session, :count)
    end

    it "shows alert on non-existent email" do
      post session_path, params: { user: { email_address: "nobody@example.com", password: "password123" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(flash[:alert]).to eq("Неверный email или пароль")
    end
  end

  describe "DELETE /session" do
    it "destroys session and redirects to login" do
      post session_path, params: { user: { email_address: user.email_address, password: "password123" } }
      expect { delete session_path }.to change(Session, :count).by(-1)
      expect(response).to redirect_to(new_session_path)
    end
  end
end
