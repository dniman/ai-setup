# frozen_string_literal: true

module Views
  module Sessions
    class NewView < Views::Base
      def initialize(flash: {})
        @flash = flash
      end

      def view_template
        if @flash[:alert]
          div(role: "alert") { @flash[:alert] }
        end

        render LoginForm.new(
          User.new,
          action: url_for(controller: "sessions", action: "create"),
          method: :post
        )

        p { a(href: new_password_path) { "Забыли пароль?" } }
      end

      class LoginForm < Superform::Rails::Form
        def view_template(&)
          render field(:email_address).label { "Email" }
          render field(:email_address).email(required: true)

          render field(:password).label { "Пароль" }
          render field(:password).password(required: true)

          submit("Войти")
        end
      end
    end
  end
end
