# Mobile App Architecture

This document describes the architecture, patterns, and guidelines of the **Rentocostume** Flutter mobile application (`apps/mobile`).

---

## 1. Architectural Overview

The mobile application is designed as a **thin client** that relies completely on the Next.js Admin server for business logic, database transactions, validation, and role-based access control (RBAC).

```
View (Widget) ──> Provider (Riverpod) ──> Repository (Dio HTTP) ──> Next.js API
```

### Core Architecture Layers:
1. **Views (UI / Presentation Layer)**: Renders UI widgets. Strictly no business logic, database references, or direct HTTP/API calls. Uses `Responsive` helpers for all layouts.
2. **Providers (State Management Layer)**: Riverpod Notifiers that wrap repositories and manage screen state (loading, error, success, local pagination).
3. **Repositories (Data Layer)**: Handles API requests via a centralized `Dio` HTTP client to communicate with the Next.js backend server.
4. **Models (Domain Layer)**: Freezed/JSON-serializable data objects reflecting API payloads.

---

## 2. Shared & Core Infrastructure

### API Communication (`lib/core/supabase/api_client.dart`)
- A centralized `ApiClient` instance handles session authentication headers, base URLs, timeouts, and JSON transformations.
- **Base URL**: `https://rentocostume-admin.vercel.app/api`
- Follows standard REST methods (`GET`, `POST`, `PATCH`, `DELETE`).

### Responsive UI Engine (`lib/core/utils/responsive.dart`)
To ensure compatibility across a variety of screen sizes:
- `Responsive.init(context)` must be called at the entry point of every screen view.
- Layout constraints must be declared using `Responsive` helpers:
  - `Responsive.sp(double)` for font sizes.
  - `Responsive.w(double)` / `Responsive.h(double)` for width and height constraints.
  - `Responsive.icon(double)` for icon sizing.
  - `Responsive.all(double)` / `Responsive.symmetric(horizontal, vertical)` for paddings and margins.

---

## 3. Layer Implementation Rules

### 1. Models (`features/<module>/models/`)
- Define all models using `freezed` and `json_serializable` for type-safety and copy utility.
- Must include `fromJson` and `toJson`.

### 2. Repositories (`features/<module>/repositories/`)
- Encapsulate Dio HTTP calls.
- Return consistent result types or models.
- Never throw exceptions to the views; capture exceptions locally and return error messages.

### 3. ViewModels / Providers (`features/<module>/viewmodels/providers/`)
- Use **Riverpod** generators and notifier classes.
- Handle state using `AsyncValue` to automatically manage loading, error, and data states.

### 4. Views (`features/<module>/views/`)
- Keep widgets below 500 lines.
- Always use `const` constructors where possible.
- Never place API or Supabase calls inside widgets.
- Use `FittedBox` for scalable text, and `Wrap` instead of `Row` for dynamic chips/tags.
