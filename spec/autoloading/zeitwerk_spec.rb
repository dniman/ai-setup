# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Zeitwerk autoloading" do
  it "passes eager loading check" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end

  it "resolves Views::Components::Base" do
    expect(Views::Components::Base.superclass).to eq(Phlex::HTML)
  end

  it "resolves Views::Base" do
    expect(Views::Base.superclass).to eq(Views::Components::Base)
  end

  it "does not define top-level Components module" do
    expect(defined?(::Components)).to be_nil
  end

  it "extends Phlex::Kit on Views::Components" do
    expect(Views::Components.singleton_class.ancestors).to include(Phlex::Kit)
  end
end
