# frozen_string_literal: true

module Views
  module Passwords
    class EditView < Views::Base
      def initialize(user:, token:)
        @user = user
        @token = token
      end

      def view_template
        render PasswordForm.new(
          @user,
          action: password_path(@token),
          method: :patch
        )
      end

      class PasswordForm < Superform::Rails::Form
        def view_template(&)
          render field(:password).label { "Новый пароль" }
          render field(:password).password(required: true, minlength: 8)

          render field(:password_confirmation).label { "Подтверждение пароля" }
          render field(:password_confirmation).password(required: true)

          if model.errors.any?
            div(role: "alert") do
              ul do
                model.errors.full_messages.each do |msg|
                  li { msg }
                end
              end
            end
          end

          submit("Сохранить пароль")
        end
      end
    end
  end
end
