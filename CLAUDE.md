See PROJECT.md for project description.

## Stack
Ruby on Rails 8.1.3, PostgreSQL, RSpec
Phlex via phlex-rails for views and layouts
Superform for forms

## Key commands
- `bin/setup` — bootstrap
- `bin/rails s` — run server
- `bundle exec rspec` — run tests
- `bin/rails db:migrate` — migrate

## Workflow (SDD)
One cycle per feature. Never proceed to next step without explicit approval.

1. **Brief** — from GitHub issue, 1-2 paragraphs max
2. **Brief Review** — check clarity, gaps, scope
3. **Spec** — generate from approved brief
4. **Spec Review** — run `/spec-reviewer:spec-review`, fix critical/high issues
5. **Implementation Plan** — generate from approved spec, list any new gems needed
6. **Plan Review** — check completeness, edge cases
7. **Implementation** — execute step by step

## Views & Components
- No .erb files — use Phlex components only
- Layouts: `app/views/layouts/` as Phlex classes
- Components: `app/views/components/`
- Naming: `Users::IndexView`, `Users::ShowView`, etc.
- Forms: Superform only, no form_with / form_for

## Documentation
Store all SDD artifacts in git alongside code:
- `docs/features/<id>-<name>/brief.md`
- `docs/features/<id>-<name>/spec.md`
- `docs/features/<id>-<name>/plan.md`

## Conventions
- Standard Rails MVC, no service objects yet
- RSpec for tests, FactoryBot for fixtures
- No new gems without explicit request (gems are agreed at Plan step)

## Constraints
- Don't touch existing migrations
- Don't implement auth
- Don't create .erb files
