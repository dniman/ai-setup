# frozen_string_literal: true

require_relative 'series'
require_relative 'nav_aria_label_attribute'
require_relative 'data_pagy_attribute'
require_relative 'a_lambda' # inherited use

class Pagy
  private

  # Common series_nav logic
  def wrap_series_nav(html, nav_classes, id: nil, aria_label: nil, **)
    data = %( #{data_pagy_attribute(:k, @update)}) if keynav?

    %(<nav#{%( id="#{id}") if id} class="#{nav_classes}" #{nav_aria_label_attribute(aria_label:)}#{data}>#{html}</nav>)
  end
end
