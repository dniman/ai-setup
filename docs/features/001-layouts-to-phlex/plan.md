# Plan: Преобразовать layouts в phlex

**Issue:** #1
**Spec:** [spec.md](spec.md)
**Branch:** feature/1-layouts-to-phlex

---

## Новые гемы

Не требуются. `phlex-rails` уже в проекте.

---

## Шаги

### 1. Создать `Views::Layouts::ApplicationLayout`

Файл: `app/views/layouts/application_layout.rb`

```ruby
class Views::Layouts::ApplicationLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype
    html do
      head do
        title { helpers.content_for(:title) || "Testops" }
        meta name: "viewport", content: "width=device-width,initial-scale=1"
        meta name: "apple-mobile-web-app-capable", content: "yes"
        meta name: "application-name", content: "Testops"
        meta name: "mobile-web-app-capable", content: "yes"
        helpers.csrf_meta_tags
        helpers.csp_meta_tag
        render helpers.content_for(:head) || ""
        link rel: "icon", href: "/icon.png", type: "image/png"
        link rel: "icon", href: "/icon.svg", type: "image/svg+xml"
        link rel: "apple-touch-icon", href: "/icon.png"
        helpers.stylesheet_link_tag :app, "data-turbo-track": "reload"
        helpers.javascript_include_tag "application", "data-turbo-track": "reload", type: "module"
      end
      body(&block)
    end
  end
end
```

### 2. Создать `Views::Layouts::MailerLayout`

Файл: `app/views/layouts/mailer_layout.rb`

```ruby
class Views::Layouts::MailerLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def view_template(&block)
    doctype
    html do
      head do
        meta "http-equiv": "Content-Type", content: "text/html; charset=utf-8"
        style { "/* Email styles need to be inline */" }
      end
      body(&block)
    end
  end
end
```

### 3. Создать `Views::Layouts::MailerTextLayout`

Файл: `app/views/layouts/mailer_text_layout.rb`

```ruby
class Views::Layouts::MailerTextLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def view_template(&block)
    plain(&block)
  end
end
```

### 4. Обновить `ApplicationController`

Файл: `app/controllers/application_controller.rb`

Добавить строку `layout -> { Views::Layouts::ApplicationLayout }` перед `allow_browser`.

### 5. Обновить `ApplicationMailer`

Файл: `app/mailers/application_mailer.rb`

Заменить `layout "mailer"` на `layout -> { Views::Layouts::MailerLayout }`.

### 6. Проверить запуск

```
bin/rails s
```

Открыть `http://localhost:3000` и убедиться в корректном рендеринге страницы.

### 7. Удалить ERB-файлы

Только после успешной проверки шага 6:

```
app/views/layouts/application.html.erb
app/views/layouts/mailer.html.erb
app/views/layouts/mailer.text.erb
```

### 8. Написать тесты

**Unit-тесты** (`spec/views/layouts/`):

- `application_layout_spec.rb` — проверить DOCTYPE, head, мета-теги, title fallback, title override, content_for(:head) без исключений
- `mailer_layout_spec.rb` — проверить http-equiv мета-тег, структуру html/head/body
- `mailer_text_layout_spec.rb` — проверить отсутствие HTML-тегов в выводе

**Request-тесты** (`spec/requests/`):

- `GET /` → HTTP 200, наличие `<meta name="csrf-param">` и `<link rel="stylesheet">`
- `GET /` → `<title>Testops</title>`

### 9. Прогнать тесты

```
bundle exec rspec spec/views/layouts/ spec/requests/
```

---

## Порядок выполнения

1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9

Шаги 1–3 независимы, можно выполнять в любом порядке.  
Шаг 7 — только после шага 6.  
Шаги 8–9 — после шага 7.
