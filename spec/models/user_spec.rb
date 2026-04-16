require "rails_helper"

RSpec.describe User, type: :model do
  subject { build(:user) }

  it "is valid with valid attributes" do
    expect(subject).to be_valid
  end

  it "is invalid without email" do
    subject.email_address = nil
    expect(subject).not_to be_valid
  end

  it "is invalid with bad email format" do
    subject.email_address = "not-an-email"
    expect(subject).not_to be_valid
  end

  it "is invalid with duplicate email (case-insensitive)" do
    create(:user, email_address: "test@example.com")
    subject.email_address = "TEST@example.com"
    expect(subject).not_to be_valid
  end

  it "is invalid with password shorter than 8 characters" do
    subject.password = "short"
    expect(subject).not_to be_valid
  end

  it "normalizes email to downcase and stripped" do
    subject.email_address = "  FOO@Bar.COM  "
    expect(subject.email_address).to eq("foo@bar.com")
  end

  it "destroys associated sessions on destroy" do
    user = create(:user)
    create(:session, user: user)
    expect { user.destroy }.to change(Session, :count).by(-1)
  end
end
