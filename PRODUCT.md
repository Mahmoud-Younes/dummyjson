# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users

Primary user: the DEPI trainer/evaluator who reviews the codebase and runs the app to grade it. Secondary user: the developer demonstrating and iterating on the work. The simulated end shopper (logging in, browsing, searching products, inspecting details) is the persona the UI serves during evaluation.

## Product Purpose

A training/portfolio Flutter app that demonstrates production-grade clean-architecture skills end to end: secure login against the dummyjson.com API, token persistence, product browsing with search, and product details. Success means a high evaluation from the DEPI program: exemplary code structure, honest QA coverage, and a UI/UX that reads as senior craft.

## Positioning

An exemplary clean-architecture Flutter reference: a small store app (login → products → details) built with strict layering (features/core, cubit, get_it DI, repositories), backed by unit + widget + e2e tests on Android and web. A neighboring project could not truthfully claim the same QA depth (full test suite, e2e suites, independent verification passes) at this scope.

## Operating Context

- Built as DEPI (Digital Egypt Pioneers Initiative) coursework on Windows.
- Demoed on the Pixel_7_Pro Android emulator and via `flutter run -d web-server` (port 8090) for browser review.
- E2E tooling lives in the sibling repo D:\flutter_p\personal_p\m\DEPI\flutter_dummyjson_auth (suites: auth, token-evidence; web and android targets).
- dummyjson.com is the fixed playground API: no real backend, no real accounts, no payments.

## Capabilities and Constraints

- Features: splash, login, sign_up, products (list + search), product_details, settings (app-bar popup: username + logout). UI language: English only. Material 3 enabled.
- Auth: dummyjson.com username/password (known demo account emilys), JWT access/refresh tokens in flutter_secure_storage (encrypted), user profile cached in shared_preferences (flutter.saved_user / flutter.last_username).
- State: cubit per feature; DI via get_it; networking via Dio with a central error handler (lib/core/networking/api_error_handler.dart) and an auth interceptor (Bearer attach + single-flight refresh on 401, session-expired returns to Login); theming centralized in lib/core/theming (styles.dart, colors.dart).
- Data is the dummyjson.com fake dataset (fixed products, images from its CDN); no cart, payments, or real user content exists.
- QA gates that must keep passing: flutter analyze (0 issues), flutter test (full suite green), web + android e2e suites green (android needs a rebuilt + reinstalled debug APK). Post-fix web e2e has not been re-run yet (open item, not a known regression).
- Windows machine constraint: kotlin.incremental=false must stay in android/gradle.properties.
- Deliberately undecided: whether cart/favorites or more features get added later.

## Brand Commitments

- Name: "DummyJSON Store" (MaterialApp title); Android label "dummyjson". No logo, tagline, or asset system exists.

## Evidence on Hand

- flutter analyze clean; flutter test 51/51; e2e android 5/5 with adb token evidence; e2e web 4/4 pre-fix (log: flutter_dummyjson_auth/out/e2e-web.log); the post-fix web run failed on a provider error and its retry was stopped by the user — never re-run.
- Repair pass 2026-11 fixed 18 findings (14 low L1-L14 + 4 medium UX M1-M4: price consistency card/details, WCAG AA contrast, double-push navigation guard, unified error translation via the core handler); report artifact "تقرير إصلاح الاكتشافات — تطبيق dummyjson".
- Must not be fabricated: no testimonials, real users, analytics, or business metrics exist.

## Product Principles

1. Evaluation-grade clarity: every screen must communicate craft to an evaluator within seconds; clarity outranks feature count.
2. Architecture is the product: design work goes through the layering (core/theming, repositories, cubit) — no bypassing layers for a visual shortcut.
3. Phone-first, web-respectful: layout and interaction decisions target the Android phone; web must stay correct and presentable but does not drive decisions.
4. Familiar patterns, executed precisely: a custom visual world is welcome inside recognizable e-commerce conventions; never trade recognizability for novelty.
5. Honest QA: no visual or UX change is "done" until analyze, tests, and the relevant e2e suite pass.

## Accessibility & Inclusion

- WCAG AA contrast (≥ 4.5:1) is the established floor for text colors (verified with computed contrast ratios in the 2026-11 repair pass).
- Icon-only controls carry tooltips/Semantics (e.g., the password visibility toggle).
