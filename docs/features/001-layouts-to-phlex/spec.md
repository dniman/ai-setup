# Spec: Преобразовать layouts в phlex

**Issue:** #1
**Brief:** [brief.md](brief.md)
**Branch:** feature/1-layouts-to-phlex

---

## 1. Обзор

Архитектурное требование проекта — отсутствие `.erb` файлов (см. CLAUDE.md: «No .erb files — use Phlex components only»). Задача конвертирует три стандартных Rails ERB-layouts в Phlex-классы, обеспечивая единообразие view-слоя. После выполнения в проекте не остаётся ни одного `.erb` layout-файла.

---

## 2. Файлы

### Создать

| Файл | Класс |
|------|-------|
| `app/views/layouts/application_layout.rb` | `Views::Layouts::ApplicationLayout` |
| `app/views/layouts/mailer_layout.rb` | `Views::Layouts::MailerLayout` |
| `app/views/layouts/mailer_text_layout.rb` | `Views::Layouts::MailerTextLayout` |

### Изменить

| Файл | Изменение |
|------|-----------|
| `app/controllers/application_controller.rb` | заменить на `layout -> { Views::Layouts::ApplicationLayout }` |
| `app/mailers/application_mailer.rb` | заменить `layout "mailer"` на `layout -> { Views::Layouts::MailerLayout }` |

### Удалить

- `app/views/layouts/application.html.erb`
- `app/views/layouts/mailer.html.erb`
- `app/views/layouts/mailer.text.erb`

> ERB-файлы удаляются только после успешного запуска `bin/rails s` и проверки корректного рендеринга страницы.

---

## 3. Реализация

### 3.1 `Views::Layouts::ApplicationLayout`

```ruby
# app/views/layouts/application_layout.rb
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
        render helpers.content_for(:head)
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

**Требования:**
- Наследует `Phlex::HTML`, включает `Phlex::Rails::Layout`
- Метод `view_template` принимает блок — содержимое страницы
- `content_for(:title)` — заголовок страницы, fallback `"Testops"`
- `content_for(:head)` — дополнительные теги в `<head>` (рендерится через `render`)
- Все мета-теги, csrf, csp, assets из оригинального ERB сохраняются

### 3.2 `Views::Layouts::MailerLayout`

```ruby
# app/views/layouts/mailer_layout.rb
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

**Требования:**
- Наследует `Phlex::HTML`, включает `Phlex::Rails::Layout`
- Воспроизводит структуру оригинального `mailer.html.erb`
- `http-equiv` мета-тег и пустой `<style>` сохраняются

### 3.3 `Views::Layouts::MailerTextLayout`

```ruby
# app/views/layouts/mailer_text_layout.rb
class Views::Layouts::MailerTextLayout < Phlex::HTML
  include Phlex::Rails::Layout

  def view_template(&block)
    plain(&block)
  end
end
```

**Требования:**
- Наследует `Phlex::HTML`, включает `Phlex::Rails::Layout`
- `Phlex::HTML` используется как базовый класс — это стандартный Phlex-подход для plain text layouts; метод `plain` рендерит переданный контент напрямую, без генерации каких-либо HTML-тегов
- Action Mailer определяет Content-Type по расширению шаблона представления (`.text.erb` → `text/plain`); layout лишь оборачивает контент, поэтому `plain` корректно выводит его без HTML-тегов
- Рендерит только plain text контент без HTML-тегов
- Соответствует оригинальному `mailer.text.erb` (`<%= yield %>`)

### 3.4 `ApplicationController`

```ruby
class ApplicationController < ActionController::Base
  layout -> { Views::Layouts::ApplicationLayout }

  allow_browser versions: :modern
end
```

**Требования:**
- `layout -> { Views::Layouts::ApplicationLayout }` — лямбда-подход для Phlex layouts
- Существующая строка `allow_browser` сохраняется

### 3.5 `ApplicationMailer`

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: "from@example.com"
  layout -> { Views::Layouts::MailerLayout }
end
```

**Требования:**
- `layout -> { Views::Layouts::MailerLayout }` — заменяет `layout "mailer"`
- `MailerTextLayout` используется как Plain Text Component в text-частях писем

---

## 4. Автозагрузка

Zeitwerk автоматически загружает `Views::Layouts::ApplicationLayout` из `app/views/layouts/application_layout.rb` благодаря phlex-rails, который добавляет `app/views` в `autoload_paths`. Ручная настройка не требуется.

---

## 5. Test Plan

### Unit-тесты (spec/views/layouts/)

**Preconditions:** тесты подключают `rails_helper` и запускаются с полным Rails-стеком, что обеспечивает доступность хелперов (`csrf_meta_tags`, `csp_meta_tag`, `stylesheet_link_tag`). Блок-контент передаётся через `render` с явным блоком: `render(Views::Layouts::ApplicationLayout.new) { "content" }`.

**ApplicationLayout:**
- рендерит `<!DOCTYPE html>` + `<html>` + `<head>` + `<body>`
- `<head>` содержит `meta[name=viewport]`, `meta[name=application-name]`
- `<title>` = «Testops» при отсутствии `content_for(:title)`
- `<title>` = переданное значение при `content_for(:title)`
- `content_for(:head)` не задан → нет исключений

**MailerLayout:**
- рендерит `<meta http-equiv="Content-Type" content="text/html; charset=utf-8">`
- рендерит структуру `<html>` + `<head>` + `<body>`

**MailerTextLayout:**
- рендерит только контент блока без HTML-тегов

### Request-тесты (spec/requests/)

- `GET /` → HTTP 200, body содержит `<meta name="csrf-param">` и `<link rel="stylesheet">`
- `GET /` → `<title>Testops</title>` при отсутствии переопределения

---

## 6. Acceptance criteria

### Структура
- [ ] `app/views/layouts/application_layout.rb` существует, класс `Views::Layouts::ApplicationLayout` определён
- [ ] `app/views/layouts/mailer_layout.rb` существует, класс `Views::Layouts::MailerLayout` определён
- [ ] `app/views/layouts/mailer_text_layout.rb` существует, класс `Views::Layouts::MailerTextLayout` определён
- [ ] `ApplicationController` использует `layout -> { Views::Layouts::ApplicationLayout }`
- [ ] `ApplicationMailer` использует `layout -> { Views::Layouts::MailerLayout }`
- [ ] Файлы `application.html.erb`, `mailer.html.erb`, `mailer.text.erb` удалены

### ApplicationLayout — рендеринг
- [ ] Страница содержит `<!DOCTYPE html>`, `<html>`, `<head>`, `<body>`
- [ ] `<head>` содержит `<meta name="viewport">`
- [ ] `<head>` содержит csrf meta tags (`<meta name="csrf-param">`, `<meta name="csrf-token">`)
- [ ] `<head>` содержит CSP meta tag
- [ ] `<head>` содержит `<link rel="icon">` (png и svg)
- [ ] `<head>` содержит `<link rel="stylesheet">` с `data-turbo-track="reload"`
- [ ] `<head>` содержит `<script type="module">` с `data-turbo-track="reload"`
- [ ] `<title>` по умолчанию содержит «Testops» при отсутствии `content_for(:title)`
- [ ] `<title>` содержит значение `content_for(:title)`, если оно задано
- [ ] `content_for(:head)` не задан → layout рендерится без исключений

### MailerLayout — рендеринг
- [ ] HTML-письмо содержит `<meta http-equiv="Content-Type" content="text/html; charset=utf-8">`
- [ ] HTML-письмо содержит `<html>`, `<head>`, `<body>`

### MailerTextLayout — рендеринг
- [ ] Text-часть письма не содержит HTML-тегов
- [ ] `MailerTextLayout` рендерит только переданный контент без обёртки

### Запуск
- [ ] `Rails.application.eager_load!` завершается без исключений (проверка автозагрузки Zeitwerk)
- [ ] `bin/rails s` запускается без ошибок

> **Откат:** ERB-файлы сохранены в git-истории и доступны через `git checkout <hash> -- app/views/layouts/`. Удалять ERB-файлы только после проверки запуска приложения.
