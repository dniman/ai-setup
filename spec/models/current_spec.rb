require "rails_helper"

RSpec.describe Current, type: :model do
  it "sets session" do
    session = create(:session)
    Current.session = session
    expect(Current.session).to eq(session)
  ensure
    Current.reset
  end

  it "delegates user to session" do
    session = create(:session)
    Current.session = session
    expect(Current.user).to eq(session.user)
  ensure
    Current.reset
  end

  it "returns nil user when no session" do
    Current.session = nil
    expect(Current.user).to be_nil
  ensure
    Current.reset
  end
end
