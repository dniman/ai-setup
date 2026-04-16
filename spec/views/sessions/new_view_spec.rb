require "rails_helper"

RSpec.describe "Sessions::NewView", type: :request do
  it "renders login form with email and password fields" do
    get new_session_path
    expect(response.body).to include('type="email"')
    expect(response.body).to include('name="user[email_address]"')
    expect(response.body).to include('type="password"')
    expect(response.body).to include('name="user[password]"')
  end

  it "renders submit button" do
    get new_session_path
    expect(response.body).to include('value="Войти"')
  end

  it "displays flash alert on failed login" do
    create(:user, email_address: "test@example.com", password: "password123")
    post session_path, params: { user: { email_address: "test@example.com", password: "wrong" } }
    expect(response.body).to include('role="alert"')
    expect(response.body).to include("Неверный email или пароль")
  end

  it "contains link to password reset" do
    get new_session_path
    expect(response.body).to include("Забыли пароль?")
    expect(response.body).to include(new_password_path)
  end
end
