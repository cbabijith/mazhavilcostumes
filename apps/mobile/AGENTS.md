# Flutter MVVM Architecture Rules

## 🚨 MANDATORY: Post-Work Build Verification
**After EVERY code change in this module, the agent MUST:**
1. Run `flutter analyze --no-pub`.
2. Fix ALL `error` and `warning` level issues before delivering to the user.
3. Verify there are no runtime issues.

## 🚫 No Automatic Git Push
- Never run `git add`, `git commit`, or `git push` automatically.
- If requested to push, target branch is `abijithcb`. NEVER push to `main`.

## 📝 Mandatory Change Explanations
- For every code change, provide a clear explanation of:
  - **What** was changed
  - **Why** the change was necessary
  - **How** the fix works

## 🔍 Mandatory Graphify Usage & Token Optimization
- **Use Graphify First**: For any codebase, directory, or structural questions, you **MUST** run `graphify query` or `query_graph` instead of doing broad grep or file searches.
- **Reference Exact Files**: Always ask the user for specific file references (e.g. `@file`) or search the graph to target files precisely, preventing unnecessary loading of files to keep prompt sizes small.
- **Atomic Tasks**: Break feature development down into small, step-by-step components (Model -> Repository -> Provider -> View) to maintain maximum accuracy and lowest token usage.

---

## Architecture

Always follow:

View
→ ViewModel
→ Repository
→ Supabase

Never skip layers.

Views must never access Supabase directly.

Views must never contain business logic.

Repositories must contain all Supabase queries.

---

## Folder Structure

Always use:

lib/
├── core/
├── features/
│   ├── auth/
│   ├── products/
│   ├── categories/
│   ├── customers/
│   ├── orders/
│   ├── payments/
│   ├── staff/
│   ├── branches/
│   ├── reports/
│   └── settings/

Every feature must contain:

models/
repositories/
viewmodels/
views/
widgets/

Never create random folders.

---

## MVVM Rules

Views:
- UI only
- No business logic
- No Supabase calls
- No complex calculations

ViewModels:
- Manage state
- Call repositories
- Handle loading and error states
- No UI widgets

Repositories:
- Supabase queries only
- CRUD operations only
- Return typed models

---

## State Management

Use Riverpod only.

Do not use:
- Provider
- GetX
- Bloc
- setState for business state

Use:
- AsyncNotifier
- Notifier
- Riverpod Generator

Prefer code generation.

---

## Navigation

Use GoRouter only.

Do not use Navigator.push directly.

All routes must be registered centrally.

---

## Models

Use Freezed.

Every model must have:

- fromJson
- toJson
- copyWith
- equality support

Never create manual model classes when Freezed can be used.

---

## Supabase

All Supabase access must go through repositories.

Never access:

Supabase.instance.client

inside views.

Create a central Supabase service.

Use dependency injection.

---

## Repository Pattern

Example:

ProductView
↓
ProductViewModel
↓
ProductRepository
↓
Supabase

Never:

ProductView
↓
Supabase

---

## Error Handling

Always use try/catch.

Return meaningful errors.

Never use empty catches.

Never swallow exceptions.

---

## Loading States

Every async action must support:

- Loading
- Success
- Error

Use AsyncValue.

---

## Naming Convention

Screens:

product_list_screen.dart
product_detail_screen.dart

ViewModels:

product_viewmodel.dart

Repositories:

product_repository.dart

Models:

product.dart

Widgets:

product_card.dart

Use snake_case filenames.

---

## UI Rules

Use:

- Material 3
- Responsive layouts
- Reusable widgets

Avoid duplicated UI.

Extract repeated widgets.

---

## Performance

Use:

- const widgets
- pagination
- lazy loading
- cached_network_image

Avoid unnecessary rebuilds.

Use Riverpod selectors where possible.

---

## Code Quality

Always:

- Use strict typing
- Use final whenever possible
- Use async/await
- Keep files focused

Avoid:

- dynamic
- any-like patterns
- huge widgets over 500 lines

---

## Feature Development Checklist

When creating a new feature:

1. Create model
2. Create repository
3. Create ViewModel
4. Create screens
5. Create widgets
6. Register routes
7. Add tests

Follow MVVM strictly.

---

## Critical Rules

Never modify architecture without permission.

Never call Supabase from UI.

Never place business logic in widgets.

Never duplicate models.

Never create multiple repositories for the same entity.

Always reuse existing ViewModels and repositories when possible.

---

## Rentocostume Business Rules

Products:
- Must support inventory tracking
- Must support branch assignment
- Must support image uploads

Orders:
- Check availability before booking
- Validate stock before confirmation
- Prevent double booking

Customers:
- Support KYC documents
- Support rental history

Payments:
- Support Cash
- Support UPI
- Support Bank Transfer

Reports:
- Revenue
- Top Costumes
- Top Customers
- GST Reports

Never bypass inventory validation.
