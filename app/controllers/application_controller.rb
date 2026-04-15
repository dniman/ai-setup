class ApplicationController < ActionController::Base
  layout -> { Views::Layouts::ApplicationLayout }

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
end
