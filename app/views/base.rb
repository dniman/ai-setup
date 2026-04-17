# frozen_string_literal: true

class Views::Base < Views::Components::Base
  # The `Views::Base` is an abstract class for all your views.

  # By default, it inherits from `Views::Components::Base`, but you
  # can change that to `Phlex::HTML` if you want to keep views and
  # components independent.

  # More caching options at https://www.phlex.fun/components/caching
  def cache_store = Rails.cache
end
