require "rails_helper"

RSpec.describe Views::Layouts::ApplicationLayout do
  let(:view_context) do
    controller = ActionController::Base.new
    controller.request = ActionDispatch::TestRequest.create
    controller.view_context
  end

  subject(:html) do
    component = described_class.new
    component.render_in(view_context) { "" }
  end

  it "renders DOCTYPE, html, head, body" do
    expect(html.downcase).to include("<!doctype html>")
    expect(html).to include("<html>")
    expect(html).to include("<head>")
    expect(html).to include("<body>")
  end

  it "renders viewport meta tag" do
    expect(html).to include('name="viewport"')
  end

  it "renders application-name meta tag" do
    expect(html).to include('name="application-name"')
  end

  it "renders default title" do
    expect(html).to include("<title>Testops</title>")
  end

  it "calls csrf_meta_tags without error" do
    # CSRF meta tags may not render in isolated test context
    # (no session/forgery protection), but the method should not raise
    expect { html }.not_to raise_error
  end

  it "renders icon links" do
    expect(html).to include('rel="icon"')
  end

  it "renders stylesheet link" do
    expect(html).to include("stylesheet")
  end

  it "does not raise when content_for(:head) is not set" do
    expect { html }.not_to raise_error
  end

  context "with content_for(:title)" do
    subject(:html) do
      view_context.content_for(:title, "Custom title")
      component = described_class.new
      component.render_in(view_context) { "" }
    end

    it "renders custom title" do
      expect(html).to include("<title>Custom title</title>")
    end
  end

  context "with content_for(:head)" do
    subject(:html) do
      view_context.content_for(:head, '<meta name="test" content="ok">'.html_safe)
      component = described_class.new
      component.render_in(view_context) { "" }
    end

    it "renders head content" do
      expect(html).to include('name="test"')
    end
  end
end
