require "rails_helper"

RSpec.describe "Passwords", type: :request do
  let(:user) { create(:user, email_address: "test@example.com", password: "password123") }

  describe "GET /passwords/new" do
    it "returns 200" do
      get new_password_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /passwords" do
    it "sends reset email for existing user" do
      expect {
        post passwords_path, params: { user: { email_address: user.email_address } }
      }.to have_enqueued_mail(PasswordsMailer, :reset)
    end

    it "does not send email for non-existent user" do
      expect {
        post passwords_path, params: { user: { email_address: "nobody@example.com" } }
      }.not_to have_enqueued_mail(PasswordsMailer, :reset)
    end

    it "responds the same regardless of email existence" do
      post passwords_path, params: { user: { email_address: "nobody@example.com" } }
      expect(response).to redirect_to(new_session_path)
      expect(flash[:notice]).to include("инструкции по сбросу пароля")
    end
  end

  describe "GET /passwords/:token/edit" do
    it "returns 200 with valid token" do
      token = user.password_reset_token
      get edit_password_path(token)
      expect(response).to have_http_status(:ok)
    end

    it "redirects with invalid token" do
      get edit_password_path("invalid-token")
      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).to include("недействительна или истекла")
    end
  end

  describe "PATCH /passwords/:token" do
    it "updates password with valid data" do
      token = user.password_reset_token
      patch password_path(token), params: { user: { password: "newpassword1", password_confirmation: "newpassword1" } }
      expect(response).to redirect_to(new_session_path)
      expect(user.reload.authenticate("newpassword1")).to be_truthy
    end

    it "destroys all user sessions on password reset" do
      create(:session, user: user)
      token = user.password_reset_token
      expect {
        patch password_path(token), params: { user: { password: "newpassword1", password_confirmation: "newpassword1" } }
      }.to change(Session, :count).by(-1)
    end

    it "re-renders form on validation error" do
      token = user.password_reset_token
      patch password_path(token), params: { user: { password: "short", password_confirmation: "short" } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
