# frozen_string_literal: true

module Views
  module Components
    extend Phlex::Kit
  end
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"), namespace: Views
)
