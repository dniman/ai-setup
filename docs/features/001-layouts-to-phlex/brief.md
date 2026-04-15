# Brief: Преобразовать layouts в phlex

**Issue:** #1
**Branch:** feature/1-layouts-to-phlex

## Контекст

Проект использует стандартные Rails ERB-layouts, которые необходимо конвертировать в Phlex-компоненты согласно архитектурным требованиям проекта (no .erb files).

В настоящее время в `app/views/layouts/` находятся три файла:
- `application.html.erb` — основной layout: DOCTYPE, head с мета-тегами, csrf, csp, assets (stylesheet + JS), именованные yield-зоны `:title` и `:head`
- `mailer.html.erb` — HTML-layout для писем: минимальный head с Content-Type, inline styles, yield body
- `mailer.text.erb` — текстовый layout для писем: только yield

## Задача

Конвертировать ERB-layouts в Phlex-классы (`phlex-rails`), разместить их в `app/views/layouts/`, после чего удалить исходные `.erb` файлы. Форм в layouts нет, Superform не требуется.

### Детали реализации

Файлы и классы:
- `app/views/layouts/application_layout.rb` → `Views::Layouts::ApplicationLayout`
- `app/views/layouts/mailer_layout.rb` → `Views::Layouts::MailerLayout`
- `app/views/layouts/mailer_text_layout.rb` → `Views::Layouts::MailerTextLayout`

Все три класса включают `Phlex::Rails::Layout`. Автозагрузка обеспечивается Zeitwerk через phlex-rails, ручная настройка не требуется.

- `ApplicationLayout`: поддерживает именованные Phlex-блоки `:title` и `:head`
- `MailerLayout`: рендерит HTML-структуру письма (head с Content-Type, inline styles, yield body)
- `MailerTextLayout`: рендерит plain text — только yield
- `ApplicationController` явно указывает `layout` на `Views::Layouts::ApplicationLayout`

## Done when

- `Views::Layouts::ApplicationLayout` реализован в `app/views/layouts/application_layout.rb`, включает `Phlex::Rails::Layout`, поддерживает блоки `:title` и `:head`
- `Views::Layouts::MailerLayout` реализован в `app/views/layouts/mailer_layout.rb`, включает `Phlex::Rails::Layout`, рендерит HTML-структуру письма
- `Views::Layouts::MailerTextLayout` реализован в `app/views/layouts/mailer_text_layout.rb`, включает `Phlex::Rails::Layout`, рендерит plain text через yield
- `ApplicationController` настроен на использование `Views::Layouts::ApplicationLayout`
- Все три `.erb` файла удалены
- `bin/rails s` запускается без ошибок
