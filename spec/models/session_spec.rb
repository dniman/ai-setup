require "rails_helper"

RSpec.describe Session, type: :model do
  it "belongs to user" do
    session = build(:session)
    expect(session.user).to be_a(User)
  end

  it "is created with ip_address and user_agent" do
    session = create(:session)
    expect(session.ip_address).to eq("127.0.0.1")
    expect(session.user_agent).to eq("RSpec Test")
  end
end
