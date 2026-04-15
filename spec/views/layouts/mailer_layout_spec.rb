require "rails_helper"

RSpec.describe Views::Layouts::MailerLayout do
  subject(:html) do
    component = described_class.new
    component.call { "email content" }
  end

  it "renders html, head, body structure" do
    expect(html).to include("<html>")
    expect(html).to include("<head>")
    expect(html).to include("<body>")
  end

  it "renders Content-Type meta tag" do
    expect(html).to include('http-equiv="Content-Type"')
    expect(html).to include('content="text/html; charset=utf-8"')
  end

  it "renders block content inside body" do
    expect(html).to include("email content")
  end
end
