require "rails_helper"

RSpec.describe Views::Layouts::MailerTextLayout do
  subject(:output) { described_class.new.call { "plain text content" } }

  it "does not produce HTML wrapper tags" do
    expect(output).not_to match(/<html|<head|<body/)
  end

  it "renders block content" do
    expect(output).to include("plain text content")
  end
end
