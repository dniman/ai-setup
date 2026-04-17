# [APPROVED] Спецификация: Исправление автозагрузки Components::Base и Views::Base

**Issue:** #5
**Бриф:** [brief.md](brief.md)

## Выбор решения

Issue предлагает три варианта. Анализ:

| Вариант | Суть | Плюсы | Минусы |
|---------|------|-------|--------|
| 1. Переименовать классы | `Components::Base` -> `Views::Components::Base` | Минимум конфигурации, всё в одном autoload path | Компоненты живут внутри `Views::` — семантически неточно |
| 2. Вынести компоненты из `app/views/` | Переместить в `app/components/` с отдельным autoload path | Чистое разделение, стандартная структура для Phlex-проектов | Перемещение файлов, новый autoload path |
| 3. Добавить второй autoload path | `app/views/components/` -> `Components::` | Компоненты остаются на месте с namespace `Components::` | Два autoload path для поддиректорий одного дерева — хрупко, Zeitwerk может конфликтовать |

**Выбран вариант 1: переименование классов.**

Обоснование:
- Минимальный объём изменений — только переименование констант, без перемещения файлов
- Zeitwerk уже ожидает `Views::Components::Base` — мы приводим код в соответствие с его ожиданиями
- `Phlex::Kit` переносится на `Views::Components` — работает аналогично
- Компоненты внутри `Views::Components::` — допустимо, т.к. `app/views/components/` физически внутри `app/views/`

## Архитектурное решение

### Иерархия после исправления

```
Phlex::HTML
├── Views::Components::Base    (app/views/components/base.rb)
│   ├── Views::Base            (app/views/base.rb)
│   │   ├── Views::Sessions::NewView
│   │   ├── Views::Passwords::NewView
│   │   └── Views::Passwords::EditView
│   └── (будущие компоненты)
├── Views::Layouts::ApplicationLayout  (без изменений)
├── Views::Layouts::MailerLayout       (без изменений)
└── Views::Layouts::MailerTextLayout   (без изменений)
```

### Изменения в файлах

#### 1. `config/initializers/phlex.rb`

Текущее состояние:
```ruby
module Views
end

module Components
  extend Phlex::Kit
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"), namespace: Views
)
```

После исправления:
```ruby
module Views
  module Components
    extend Phlex::Kit
  end
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"), namespace: Views
)
```

Что изменилось:
- `Components` (top-level) заменён на `Views::Components`
- `Phlex::Kit` теперь extend'ит `Views::Components`
- Autoload path остаётся один — `app/views/` -> `Views`

#### 2. `app/views/components/base.rb`

Текущее состояние:
```ruby
class Components::Base < Phlex::HTML
```

После исправления:
```ruby
class Views::Components::Base < Phlex::HTML
```

Остальное содержимое файла не меняется (include'ы, `before_template`).

#### 3. `app/views/base.rb`

Текущее состояние:
```ruby
class Views::Base < Components::Base
```

После исправления:
```ruby
class Views::Base < Views::Components::Base
```

Также обновляется комментарий в файле: `Components::Base` → `Views::Components::Base`.

#### 4. `app/views/sessions/new_view.rb`

Текущее состояние:
```ruby
class NewView < Phlex::HTML
  include Phlex::Rails::Helpers::Routes
```

После исправления:
```ruby
class NewView < Views::Base
```

Удаляется `include Phlex::Rails::Helpers::Routes` — он уже есть в `Views::Components::Base`.

#### 5. `app/views/passwords/new_view.rb`

Аналогично п.4: `Phlex::HTML` -> `Views::Base`, удаление `include Phlex::Rails::Helpers::Routes`.

#### 6. `app/views/passwords/edit_view.rb`

Аналогично п.4: `Phlex::HTML` -> `Views::Base`, удаление `include Phlex::Rails::Helpers::Routes`.

### Файлы без изменений

- `app/views/layouts/application_layout.rb` — наследуется от `Phlex::HTML`, включает `Phlex::Rails::Layout`. Не использует `Views::Base`, не затрагивается.
- `app/views/layouts/mailer_layout.rb` — аналогично.
- `app/views/layouts/mailer_text_layout.rb` — аналогично.

## Rollback plan

Все изменения вносятся одним коммитом/PR. В случае проблем после деплоя — revert коммита. Промежуточных миграций нет, откат атомарный.

## Закрытие открытого вопроса из брифа

**Вопрос:** какой namespace у базового класса компонентов?
**Ответ:** `Views::Components::Base`. Это следует из выбора варианта 1 — приведение имён классов к ожиданиям Zeitwerk для структуры `app/views/components/`.

## Edge cases

### 1. Ссылки на `Components::Base` в других местах кода

После переименования top-level `Components` исчезает. Результаты `grep -r 'Components::' по кодовой базе (исключая docs/):

| Файл | Строка | Действие |
|------|--------|----------|
| `config/initializers/phlex.rb:6` | `module Components` | Переносится в `Views::Components` (п.1 изменений) |
| `app/views/components/base.rb:3` | `class Components::Base < Phlex::HTML` | Переименовывается в `Views::Components::Base` (п.2) |
| `app/views/base.rb:3` | `class Views::Base < Components::Base` | Обновляется на `Views::Components::Base` (п.3) |
| `app/views/base.rb:6` | Комментарий: `# By default, it inherits from Components::Base` | Обновить комментарий на `Views::Components::Base` |

**В тестах (`spec/`):** ноль ссылок на `Components::` — обновление тестов не требуется.

**Строковые ссылки:** `grep` по `"Components"`, `'Components'` и `constantize` в `.rb`-файлах — ноль совпадений. Динамических обращений к `::Components::Base` через `constantize` нет.

**Поведение после удаления:** обращение к `::Components::Base` вызовет `NameError`. Deprecation-алиас не нужен — ссылок нет.

**Вывод:** все ссылки покрыты пунктами 1–3 изменений + обновление комментария в `app/views/base.rb`.

### 2. Вложенные Superform-классы в вью

Вью содержат вложенные классы форм:
- `Views::Sessions::NewView::LoginForm < Superform::Rails::Form`
- `Views::Passwords::NewView::ResetForm < Superform::Rails::Form`
- `Views::Passwords::EditView::PasswordForm < Superform::Rails::Form`

Формы наследуются от `Superform::Rails::Form`, не от Phlex-классов. Смена базового класса родительского вью (`Phlex::HTML` → `Views::Base`) не затрагивает вложенные формы — они рендерятся через `render FormClass.new(...)`, что является стандартным Phlex-механизмом. Риск: минимальный.

### 3. `Phlex::Kit` поведение

`Phlex::Kit` при `extend` добавляет `const_missing` в модуль, позволяя использовать короткие имена компонентов. После переноса:

- `Views::Components.extend Phlex::Kit` — `const_missing` работает на модуле `Views::Components`
- Компоненты доступны как `Views::Components::MyComponent`
- Для shorthand: `include Views::Components` в нужном контексте → можно писать `MyComponent`

Текущих компонентов кроме `Views::Components::Base` нет, shorthand-синтаксис нигде не используется. Риск: нулевой для текущего состояния кода.

### 4. Порядок загрузки initializer vs Zeitwerk

`config/initializers/phlex.rb` выполняется при boot до autoload. Модуль `Views::Components` определяется в initializer, Zeitwerk знает о директории `app/views/components/` и ожидает модуль `Views::Components`. Конфликта нет — Zeitwerk переиспользует уже определённый модуль. `extend Phlex::Kit` сохраняется, т.к. Zeitwerk не переопределяет модуль, а только регистрирует ожидание.

## Тестовая стратегия

### Новые тесты (autoloading)

```ruby
# spec/autoloading/zeitwerk_spec.rb
RSpec.describe "Zeitwerk autoloading" do
  it "passes eager loading check" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end

  it "resolves Views::Components::Base" do
    expect(Views::Components::Base.superclass).to eq(Phlex::HTML)
  end

  it "resolves Views::Base" do
    expect(Views::Base.superclass).to eq(Views::Components::Base)
  end

  it "does not define top-level Components module" do
    expect(defined?(::Components)).to be_nil
  end

  it "extends Phlex::Kit on Views::Components" do
    expect(Views::Components.singleton_class.ancestors).to include(Phlex::Kit)
  end

  it "resolves components via Phlex::Kit const_missing" do
    stub_const("Views::Components::TestWidget", Class.new(Views::Components::Base))
    expect(Views::Components::TestWidget.superclass).to eq(Views::Components::Base)
  end
end
```

### Проверка наследования хелперов

```ruby
# spec/views/base_spec.rb
RSpec.describe Views::Base do
  it "includes Phlex::Rails::Helpers::Routes" do
    expect(Views::Base.ancestors).to include(Phlex::Rails::Helpers::Routes)
  end
end
```

### Существующие тесты (smoke)

Существующие request-тесты покрывают рендеринг authentication вью:
- `spec/requests/sessions_spec.rb` — GET /session/new, POST /session
- `spec/requests/passwords_spec.rb` — GET /passwords/new, POST /passwords, GET /passwords/:token/edit, PATCH /passwords/:token

Эти тесты валидируют что вью рендерятся корректно после смены базового класса. Дополнительные view-тесты не требуются — request-тесты достаточны как smoke tests.

### Команды проверки

- `bin/rails zeitwerk:check` — проверка корректности autoload mapping (eager loading mode)
- `bundle exec rspec` — полный тестовый набор

## Соответствие критериям приёмки

| Критерий | Как обеспечивается | Как проверяется |
|----------|-------------------|-----------------|
| `Views::Base` загружается без ошибок | Zeitwerk находит `app/views/base.rb`, класс наследует от `Views::Components::Base` — всё в namespace `Views` | `Rails.application.eager_load!` без ошибок; `Views::Base.superclass == Views::Components::Base` |
| Базовый класс компонентов загружается | `app/views/components/base.rb` определяет `Views::Components::Base` — совпадает с ожиданиями Zeitwerk | `Views::Components::Base.superclass == Phlex::HTML` |
| Вью получают хелперы (`Phlex::Rails::Helpers::Routes`) и dev-комментарии (`before_template`) | `Views::Base` -> `Views::Components::Base` — include'ы и `before_template` наследуются | `Views::Base.ancestors.include?(Phlex::Rails::Helpers::Routes)` |
| Вью из authentication работают на `Views::Base` | `NewView < Views::Base` вместо `Phlex::HTML`, дублирующие include'ы удалены | Request-тесты sessions/passwords проходят |
| Лейауты работают без изменений | Лейауты наследуются от `Phlex::HTML` напрямую, включают `Phlex::Rails::Layout`. Не используют `Views::Base`, не затрагиваются | Существующие request-тесты проходят |
| `bin/rails zeitwerk:check` проходит | Все классы соответствуют ожиданиям Zeitwerk для файловой структуры | `bin/rails zeitwerk:check` завершается без ошибок |
| Тесты проходят | Нет изменений в логике, только namespace и базовый класс. В тестах ссылок на `Components::` нет | `bundle exec rspec` — green suite |

> **[Approved by @dniman 2026-04-16]**
> Спецификация прошла архитектурное и бизнес-ревью.
> Итераций: 1. Исправлено проблем: 13 (2 critical, 11 high).

---
_Spec Review v1.11.0 | 2026-04-16_
