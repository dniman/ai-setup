# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Base do
  it "includes Phlex::Rails::Helpers::Routes" do
    expect(Views::Base.ancestors).to include(Phlex::Rails::Helpers::Routes)
  end
end
