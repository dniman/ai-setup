# План реализации: Исправление автозагрузки Components::Base и Views::Base

**Issue:** #5
**Спецификация:** [spec.md](spec.md)

## Порядок выполнения

### Шаг 1. Исправить initializer `config/initializers/phlex.rb`

**Файл:** `config/initializers/phlex.rb`

Заменить top-level `module Components` на вложенный `Views::Components`:

```ruby
# frozen_string_literal: true

module Views
  module Components
    extend Phlex::Kit
  end
end

Rails.autoloaders.main.push_dir(
  Rails.root.join("app/views"), namespace: Views
)
```

**Проверка:** `bin/rails zeitwerk:check` (ожидаемо: пока падает, т.к. `components/base.rb` ещё определяет `Components::Base`).

### Шаг 2. Переименовать `Components::Base` → `Views::Components::Base`

**Файл:** `app/views/components/base.rb`

Строка 3: `class Components::Base < Phlex::HTML` → `class Views::Components::Base < Phlex::HTML`

### Шаг 3. Обновить `Views::Base` — наследование и комментарий

**Файл:** `app/views/base.rb`

- Строка 3: `class Views::Base < Components::Base` → `class Views::Base < Views::Components::Base`
- Строка 6: комментарий `Components::Base` → `Views::Components::Base`

**Проверка:** `bin/rails zeitwerk:check` — должен пройти без ошибок.

### Шаг 4. Перевести вью на `Views::Base` и удалить дублирующиеся include'ы

Для каждого файла: заменить `< Phlex::HTML` на `< Views::Base` и удалить `include Phlex::Rails::Helpers::Routes`.

**4a. `app/views/sessions/new_view.rb`**

```ruby
class NewView < Views::Base
  # удалить: include Phlex::Rails::Helpers::Routes
```

**4b. `app/views/passwords/new_view.rb`**

```ruby
class NewView < Views::Base
  # удалить: include Phlex::Rails::Helpers::Routes
```

**4c. `app/views/passwords/edit_view.rb`**

```ruby
class EditView < Views::Base
  # удалить: include Phlex::Rails::Helpers::Routes
```

### Шаг 5. Написать тесты автозагрузки

**Новый файл:** `spec/autoloading/zeitwerk_spec.rb`

```ruby
# frozen_string_literal: true

require "rails_helper"

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
end
```

### Шаг 6. Написать тест наследования хелперов

**Новый файл:** `spec/views/base_spec.rb`

```ruby
# frozen_string_literal: true

require "rails_helper"

RSpec.describe Views::Base do
  it "includes Phlex::Rails::Helpers::Routes" do
    expect(Views::Base.ancestors).to include(Phlex::Rails::Helpers::Routes)
  end
end
```

### Шаг 7. Прогнать полный тестовый набор

```bash
bin/rails zeitwerk:check
bundle exec rspec
```

Все тесты должны быть зелёными, включая:
- Новые тесты автозагрузки (`spec/autoloading/zeitwerk_spec.rb`)
- Тест наследования (`spec/views/base_spec.rb`)
- Существующие request-тесты sessions и passwords (smoke-проверка рендеринга вью)
- Все остальные существующие тесты (регрессия)

## Файлы, которые будут изменены

| Файл | Тип изменения |
|------|---------------|
| `config/initializers/phlex.rb` | Редактирование |
| `app/views/components/base.rb` | Редактирование |
| `app/views/base.rb` | Редактирование |
| `app/views/sessions/new_view.rb` | Редактирование |
| `app/views/passwords/new_view.rb` | Редактирование |
| `app/views/passwords/edit_view.rb` | Редактирование |
| `spec/autoloading/zeitwerk_spec.rb` | Новый файл |
| `spec/views/base_spec.rb` | Новый файл |

## Файлы без изменений

- `app/views/layouts/application_layout.rb` — наследуется от `Phlex::HTML`, не затрагивается
- `app/views/layouts/mailer_layout.rb` — аналогично
- `app/views/layouts/mailer_text_layout.rb` — аналогично
- Все существующие тесты — ссылок на `Components::` нет

## Новые гемы

Не требуются.

## Риски

Минимальные. Все изменения — переименование namespace и смена базового класса. Логика вью не затрагивается. Откат — revert одного коммита.
