# frozen_string_literal: true

module Views
  module Passwords
    class NewView < Phlex::HTML
      include Phlex::Rails::Helpers::Routes

      def view_template
        render ResetForm.new(
          User.new,
          action: passwords_path,
          method: :post
        )

        p { a(href: new_session_path) { "Вернуться к входу" } }
      end

      class ResetForm < Superform::Rails::Form
        def view_template(&)
          render field(:email_address).label { "Email" }
          render field(:email_address).email(required: true)

          submit("Отправить ссылку для сброса")
        end
      end
    end
  end
end
