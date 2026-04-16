# [APPROVED] Спецификация: Аутентификация пользователей

**Issue:** #3
**Бриф:** [brief.md](brief.md)

## 1. Модель User

### Таблица `users`

| Колонка           | Тип      | Ограничения                     |
|-------------------|----------|---------------------------------|
| `id`              | bigint   | PK                              |
| `email_address`   | string   | NOT NULL, UNIQUE, index         |
| `password_digest` | string   | NOT NULL                        |
| `created_at`      | datetime | NOT NULL                        |
| `updated_at`      | datetime | NOT NULL                        |

### Модель

- `has_secure_password` (гем `bcrypt` — раскомментировать в Gemfile перед реализацией).
- `has_many :sessions, dependent: :destroy`.
- Валидации:
  - `email_address` — presence, uniqueness (case-insensitive), формат.
  - `password` — presence, minimum 8 символов (при создании / смене).
- `email_address` нормализуется к нижнему регистру и убираются пробелы.

## 2. Модель Session

### Таблица `sessions`

| Колонка      | Тип        | Ограничения            |
|--------------|------------|------------------------|
| `id`         | bigint     | PK                     |
| `user_id`    | bigint     | NOT NULL, FK, index    |
| `ip_address` | string     |                        |
| `user_agent` | string     |                        |
| `created_at` | datetime   | NOT NULL               |
| `updated_at` | datetime   | NOT NULL               |

### Модель

- `belongs_to :user`.
- Хранит информацию о каждой активной сессии пользователя.

## 3. Модель Current

- Наследует от `ActiveSupport::CurrentAttributes`.
- Атрибут `session`.
- Делегирует `user` на `session`.

## 4. Маршруты

```
resource  :session                         — вход / выход
resources :passwords, param: :token        — восстановление пароля
```

> **Примечание:** `root_path` используется для редиректов после входа. Определяется в другой фиче. При реализации создать заглушку (например, статическая страница) если root_path ещё не задан.

Конкретные пути:

| Метод  | Путь                    | Действие                |
|--------|-------------------------|-------------------------|
| GET    | /session/new            | Форма входа             |
| POST   | /session                | Аутентификация          |
| DELETE | /session                | Выход                   |
| GET    | /passwords/new          | Форма запроса сброса    |
| POST   | /passwords              | Отправка email сброса   |
| GET    | /passwords/:token/edit  | Форма нового пароля     |
| PATCH  | /passwords/:token       | Сохранение нового пароля|

## 5. Concern Authentication

Подключается в `ApplicationController`. Предоставляет:

- `require_authentication` — `before_action`, редирект на форму входа если сессия не найдена.
- `resume_session` — восстанавливает сессию из cookie.
- `start_new_session_for(user)` — создаёт запись `Session` в БД, устанавливает signed cookie.
- `terminate_session` — удаляет запись сессии из БД, очищает cookie.
- Маршрут `/up` (health check) — остаётся доступным без аутентификации.

## 6. SessionsController

### `new`
- Если пользователь уже аутентифицирован — редирект на `root_path`.
- Иначе — рендерит форму входа.

### `create`
- Ищет пользователя по `email_address`.
- Если найден и пароль верный — `start_new_session_for(user)`, редирект на `root_path`.
- Если нет — рендерит форму с flash[:alert] "Неверный email или пароль" (не уточнять, что именно неверно). Поле email сохраняет введённое значение, поле пароля очищается.

### `destroy`
- `terminate_session`.
- Редирект на `/session/new`.

## 7. PasswordsController

### `new`
- Форма запроса сброса пароля (поле email).

### `create`
- Ищет пользователя по `email_address`.
- Если найден — отправляет email с токеном сброса через `PasswordsMailer`.
- Всегда показывает одно и то же сообщение (не раскрывать, существует ли email).

### `edit`
- Находит пользователя по signed-токену из URL.
- Если токен невалиден или истёк — редирект на `/passwords/new` с flash[:alert] "Ссылка для сброса пароля недействительна или истекла. Запросите новую."
- Рендерит форму ввода нового пароля.

### `update`
- Находит пользователя по токену.
- Если токен невалиден или истёк — редирект на `/passwords/new` с flash[:alert] (аналогично `edit`).
- Если новый пароль не проходит валидацию (< 8 символов) — re-render формы `edit` с inline ошибками. Токен остаётся валидным в пределах TTL.
- При успешном обновлении — все существующие сессии пользователя удаляются (`user.sessions.destroy_all`).
- Редирект на форму входа с flash[:notice] "Пароль успешно изменён. Войдите с новым паролем."

## 8. PasswordsMailer

- Метод `reset` — отправляет email со ссылкой на сброс пароля. Отправка асинхронная через Active Job. При сбое SMTP — стандартный retry (3 попытки).
- Ссылка содержит signed-токен с TTL **1 час** (`expires_in: 1.hour`, `purpose: :password_reset`).
- Токен фактически одноразовый: после успешной смены пароля `password_digest` меняется, что автоматически инвалидирует ранее выданный signed-токен.

## 9. Представления (Phlex)

Генератор создаёт ERB-шаблоны, которые заменяются на Phlex-компоненты:

| ERB (генерируется)                    | Phlex (заменяем на)                        |
|---------------------------------------|--------------------------------------------|
| `sessions/new.html.erb`               | `Sessions::NewView`                        |
| `passwords/new.html.erb`              | `Passwords::NewView`                       |
| `passwords/edit.html.erb`             | `Passwords::EditView`                      |
| `passwords_mailer/reset.html.erb`     | Оставить ERB или Phlex (решаем в плане)   |
| `passwords_mailer/reset.text.erb`     | Оставить ERB (текстовый формат)           |

Формы строятся через Superform.

### Sessions::NewView (форма входа)

- Поля: `email_address` (type=email, required, label "Email"), `password` (type=password, required, label "Пароль").
- Кнопка: "Войти".
- Ссылка: "Забыли пароль?" → `/passwords/new`.
- Flash[:alert] отображается над формой (role="alert").
- Все поля имеют `<label>`, ошибки связаны через `aria-describedby`.

### Passwords::NewView (запрос сброса пароля)

- Поле: `email_address` (type=email, required, label "Email").
- Кнопка: "Отправить ссылку для сброса".
- Ссылка: "Вернуться к входу" → `/session/new`.
- После отправки: flash[:notice] "Если аккаунт с таким email существует, мы отправили инструкции по сбросу пароля."

### Passwords::EditView (новый пароль)

- Поля: `password` (type=password, required, min 8, label "Новый пароль"), `password_confirmation` (type=password, required, label "Подтверждение пароля").
- Кнопка: "Сохранить пароль".
- Inline ошибки валидации у соответствующих полей.

## 10. Seed-данные

Seed-данные предназначены только для development/test окружений:

```ruby
if Rails.env.development? || Rails.env.test?
  User.find_or_create_by!(email_address: "admin@example.com") do |user|
    user.password = "password123"
  end
end
```

Для production — rake-задача:

```
bin/rails "users:create[email@example.com, password]"
```

## 11. Безопасность

- Пароли хранятся как bcrypt-хеш (`password_digest`).
- Сессии хранятся в БД — можно инвалидировать серверно.
- Cookie сессии — permanent signed, httponly, secure (production), SameSite=Lax.
- CSRF-защита включена (Rails по умолчанию).
- Токен сброса пароля — signed с TTL 1 час (`purpose: :password_reset`).
- Сообщения об ошибках не раскрывают существование email в системе.
- `force_ssl` включён в production (TLS 1.2+).
- Блокировка при брутфорсе — вне scope (см. issue #4).

## 12. Out of scope

- Публичная регистрация.
- Создание аккаунтов администратором через интерфейс.
- Разграничение ролей.
- Блокировка при неудачных попытках входа.

## 13. Тест-кейсы

### Модель User
- Валидный пользователь создаётся успешно.
- Невалидный email — ошибка валидации.
- Дублирующийся email (case-insensitive) — ошибка валидации.
- Пароль короче 8 символов — ошибка валидации.

### Вход
- Верный email + пароль — редирект на `root_path`, сессия создана в БД.
- Неверный пароль — форма с ошибкой, сессия не создана.
- Несуществующий email — форма с ошибкой, сессия не создана.
- Уже аутентифицированный пользователь заходит на `/session/new` — редирект на `root_path`.

### Выход
- DELETE `/session` — запись сессии удалена из БД, cookie очищена, редирект на `/session/new`.

### Восстановление пароля
- Запрос сброса для существующего email — email отправлен.
- Запрос сброса для несуществующего email — ответ тот же (без утечки информации).
- Переход по валидной ссылке сброса — форма нового пароля.
- Переход по истёкшей/невалидной ссылке — редирект на `/passwords/new` с flash[:alert].
- Установка нового пароля — пароль обновлён, все сессии удалены, редирект на форму входа с flash[:notice].
- Невалидный новый пароль (< 8 символов) — re-render формы с inline ошибками.

### Модель Session
- Создание сессии с user_id, ip_address, user_agent.
- belongs_to :user — обязательная связь.
- Каскадное удаление сессий при удалении пользователя (`dependent: :destroy`).

### Current
- `Current.session=` устанавливает сессию.
- `Current.user` делегирует на `session.user`.

### PasswordsMailer
- `reset` отправляет email на правильный адрес.
- Email содержит ссылку `/passwords/:token/edit`.
- Отправка асинхронная (Active Job).

### Защита страниц
- Неаутентифицированный запрос на любую страницу — редирект на `/session/new`.
- Аутентифицированный запрос — доступ разрешён.
- `/up` (health check) — доступен без аутентификации.

---

> **[Approved by @dniman 2026-04-15]**
> Спецификация прошла архитектурное и бизнес-ревью.
> Итераций: 1. Исправлено проблем: 15. Отложено: 1 (issue #4).

---
_Spec Review v1.11.0 | 2026-04-15_
