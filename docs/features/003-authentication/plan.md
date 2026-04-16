# [APPROVED] План реализации: Аутентификация пользователей

**Issue:** #3
**Спецификация:** [spec.md](spec.md)

## Стратегия

Используем встроенный генератор `bin/rails generate authentication` (Rails 8.1) как основу.
Генератор создаёт: модели (User, Session, Current), контроллеры (SessionsController, PasswordsController),
concern Authentication, mailer, миграции, маршруты, раскомментирует bcrypt.
После генерации адаптируем результат под проект: ERB → Phlex + Superform, русификация,
дополнительные валидации по спеке, тесты на RSpec вместо Minitest.

## Новые гемы

- `bcrypt` — генератор раскомментирует автоматически.

## Шаги реализации

### Шаг 1. Запуск генератора

```bash
bin/rails generate authentication
bin/rails db:migrate
```

Генератор создаст:

| Файл | Что делает |
|------|------------|
| `app/models/user.rb` | Модель с `has_secure_password`, `has_many :sessions` |
| `app/models/session.rb` | Модель с `belongs_to :user` |
| `app/models/current.rb` | `ActiveSupport::CurrentAttributes` |
| `app/controllers/concerns/authentication.rb` | Concern с `require_authentication`, `resume_session`, etc. |
| `app/controllers/sessions_controller.rb` | Вход / выход |
| `app/controllers/passwords_controller.rb` | Сброс пароля |
| `app/mailers/passwords_mailer.rb` | Email сброса пароля |
| `app/views/sessions/new.html.erb` | Форма входа (ERB) |
| `app/views/passwords/new.html.erb` | Форма запроса сброса (ERB) |
| `app/views/passwords/edit.html.erb` | Форма нового пароля (ERB) |
| `app/views/passwords_mailer/reset.html.erb` | HTML email |
| `app/views/passwords_mailer/reset.text.erb` | Текстовый email |
| `test/mailers/previews/passwords_mailer_preview.rb` | Preview для mailer |
| `db/migrate/*_create_users.rb` | Миграция users |
| `db/migrate/*_create_sessions.rb` | Миграция sessions |

Также модифицирует: `Gemfile` (раскомментирует bcrypt), `config/routes.rb`, `app/controllers/application_controller.rb`.

### Шаг 2. Удаление сгенерированных ERB-шаблонов и настройка root

Удалить файлы, которые будут заменены на Phlex:

```
app/views/sessions/new.html.erb
app/views/passwords/new.html.erb
app/views/passwords/edit.html.erb
```

Mailer-шаблоны оставить как ERB — стандартная практика для email.

Добавить заглушку `root` в `config/routes.rb`:

```ruby
root "sessions#new"
```

> Заглушка нужна сразу — `root_path` используется в редиректах (шаги 6, 8).

### Шаг 3. Доработка модели User

Генератор создаёт базовую модель. Дополнить по спеке:

- Валидация `email_address` — presence, uniqueness (case_sensitive: false), формат.
- Валидация `password` — minimum 8 символов (при создании / смене).
- `normalizes :email_address` — downcase, strip.

> Генератор уже добавляет `has_secure_password`, `has_many :sessions`, `normalizes`.
> Нужно проверить и дополнить валидации, которых нет из коробки.

### Шаг 4. Фабрики

- `spec/factories/users.rb` — email, password.
- `spec/factories/sessions.rb` — user, ip_address, user_agent.

### Шаг 5. Тесты моделей

**5a. `spec/models/user_spec.rb`**

- Валидный пользователь создаётся успешно.
- Невалидный email — ошибка валидации.
- Дублирующийся email (case-insensitive) — ошибка валидации.
- Пароль < 8 символов — ошибка валидации.
- `has_many :sessions, dependent: :destroy`.

**5b. `spec/models/session_spec.rb`**

- `belongs_to :user`.
- Создание с ip_address, user_agent.

**5c. `spec/models/current_spec.rb`**

- `Current.session=` устанавливает сессию.
- `Current.user` делегирует на `session.user`.

Запустить: `bundle exec rspec spec/models/`.

### Шаг 6. Phlex-представление Sessions::NewView

**`app/views/sessions/new_view.rb`**

- Superform-форма: email_address (type=email, required, label "Email"), password (type=password, required, label "Пароль").
- Кнопка "Войти".
- Ссылка "Забыли пароль?" → `new_password_path`.
- Flash[:alert] над формой (role="alert").
- Labels, aria-describedby для ошибок.

### Шаг 7. Доработка SessionsController

Сгенерированный контроллер адаптировать:

- Генератор добавляет `allow_unauthenticated_access` — убедиться, что он присутствует (исключает контроллер из `require_authentication`).
- `new` — добавить проверку: если уже аутентифицирован — редирект на `root_path`.
- `create` — flash[:alert] "Неверный email или пароль". Рендер Phlex-вью вместо ERB.
- `destroy` — без изменений (генератор делает правильно).

### Шаг 8. Тесты входа/выхода

**`spec/requests/sessions_spec.rb`**

- GET `/session/new` — 200.
- POST `/session` с верными данными — редирект на `root_path`, сессия создана.
- POST `/session` с неверным паролем — flash[:alert], сессия не создана.
- POST `/session` с несуществующим email — flash[:alert], сессия не создана.
- GET `/session/new` аутентифицированным — редирект на `root_path`.
- DELETE `/session` — сессия удалена, cookie очищена, редирект на `/session/new`.

**`spec/views/sessions/new_view_spec.rb`**

- Рендерит форму с полями email и password.
- Отображает flash[:alert].
- Содержит ссылку на сброс пароля.

Запустить: `bundle exec rspec spec/requests/sessions_spec.rb spec/views/sessions/`.

### Шаг 9. Phlex-представления паролей

**9a. `app/views/passwords/new_view.rb`** — Passwords::NewView

- Superform-форма: email_address (type=email, required, label "Email").
- Кнопка "Отправить ссылку для сброса".
- Ссылка "Вернуться к входу" → `new_session_path`.

**9b. `app/views/passwords/edit_view.rb`** — Passwords::EditView

- Superform-форма: password (type=password, required, min 8, label "Новый пароль"), password_confirmation (type=password, required, label "Подтверждение пароля").
- Кнопка "Сохранить пароль".
- Inline ошибки валидации.

### Шаг 10. Доработка PasswordsController

Сгенерированный контроллер адаптировать:

- Генератор добавляет `allow_unauthenticated_access` — убедиться, что он присутствует.
- Рендер Phlex-вью вместо ERB.
- `create` — flash[:notice] "Если аккаунт с таким email существует, мы отправили инструкции по сбросу пароля."
- `edit` — при невалидном токене: flash[:alert] "Ссылка для сброса пароля недействительна или истекла. Запросите новую."
- `update` — при успехе: flash[:notice] "Пароль успешно изменён. Войдите с новым паролем." Все сессии пользователя удаляются (`user.sessions.destroy_all`).
- `update` — при ошибке валидации: re-render формы `edit` с inline ошибками.

### Шаг 11. Тесты восстановления пароля

**`spec/requests/passwords_spec.rb`**

- GET `/passwords/new` — 200.
- POST `/passwords` с существующим email — email отправлен (assert_enqueued_emails).
- POST `/passwords` с несуществующим email — ответ тот же, email не отправлен.
- GET `/passwords/:token/edit` с валидным токеном — 200.
- GET `/passwords/:token/edit` с невалидным/истёкшим — редирект с flash[:alert].
- PATCH `/passwords/:token` с валидным паролем — пароль обновлён, сессии удалены, редирект.
- PATCH `/passwords/:token` с невалидным паролем — re-render с ошибками.

**`spec/mailers/passwords_mailer_spec.rb`**

- `reset` отправляет на правильный адрес.
- Email содержит ссылку `/passwords/:token/edit`.
- Отправка асинхронная (deliver_later).

**`spec/views/passwords/new_view_spec.rb`** и **`spec/views/passwords/edit_view_spec.rb`**

Запустить: `bundle exec rspec spec/requests/passwords_spec.rb spec/mailers/ spec/views/passwords/`.

### Шаг 12. Защита страниц и health check

**`spec/requests/authentication_spec.rb`**

- Неаутентифицированный запрос на `root_path` — редирект на `/session/new` (root ведёт на `sessions#new`, но `require_authentication` сработает для контроллеров без `allow_unauthenticated_access`).
- Для полноценного теста: определить анонимный контроллер в спеке (через `controller { }` block или отдельный тестовый контроллер в `spec/support/`) — проверить, что `require_authentication` из `ApplicationController` работает.
- Аутентифицированный запрос — 200.
- GET `/up` — 200 без аутентификации.

### Шаг 13. Seed-данные и rake-задача

**13a. `db/seeds.rb`** — добавить seed-пользователя:

```ruby
if Rails.env.development? || Rails.env.test?
  User.find_or_create_by!(email_address: "admin@example.com") do |user|
    user.password = "password123"
  end
end
```

**13b. `lib/tasks/users.rake`** — rake-задача для production:

```ruby
namespace :users do
  desc "Create a user: bin/rails 'users:create[email, password]'"
  task :create, [:email, :password] => :environment do |_t, args|
    User.create!(email_address: args[:email], password: args[:password])
    puts "User #{args[:email]} created."
  end
end
```

### Шаг 14. Удаление Minitest-артефактов

Удалить `test/mailers/previews/passwords_mailer_preview.rb` и переместить в `spec/mailers/previews/passwords_mailer_preview.rb`. Это тот же `ActionMailer::Preview`-класс — он работает одинаково и с Minitest, и с RSpec. Нужно только убедиться, что `config.action_mailer.preview_paths` включает `spec/mailers/previews`.

### Шаг 15. Финальная проверка

- `bundle exec rspec` — все тесты проходят.
- `bin/rails db:migrate:reset db:seed` — БД пересоздаётся без ошибок.
- Ручная проверка в браузере: вход, выход, сброс пароля, защита страниц.

---

> **[Approved by @dniman 2026-04-15]**
> План прошёл ревью. Исправлено: порядок шагов (root раньше, вью до контроллеров),
> уточнены allow_unauthenticated_access, тестирование защиты страниц, mailer preview.
