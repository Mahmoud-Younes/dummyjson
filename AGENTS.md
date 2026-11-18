# AGENTS.md

Flutter app (Android + Web) consuming the DummyJSON fake REST API (`https://dummyjson.com`). Features: splash (auto-login check), login (token auth), sign up (fake account creation, saves the username for login prefill, then back to login), settings (app-bar popup: username + logout, reusing LoginRepo), products (list + search), product details. After login (and after splash auto-login) the app lands directly on the Products screen — the post-login root, no back button on it.

This is a learning project (DEPI course): files carry deliberate beginner-teaching comments (analogies like "waiter"/"kitchen"). Keep that comment style when editing.

## Commands

On this Windows box, spawned processes can fail to resolve `flutter` (extensionless shim) with ENOENT. Use `cmd /c flutter ...` or the full path `C:/Users/Younes/dev/flutter/bin/flutter.bat`.

    cmd /c flutter pub get
    cmd /c flutter analyze                      # lint/static analysis (flutter_lints)
    cmd /c flutter test                         # unit + widget tests in test/
    cmd /c flutter test test/login_cubit_test.dart   # single file

Run for web — e2e expects the app at `http://127.0.0.1:8090`; start it by hand and keep it running (do NOT let a test harness spawn it; orphaned processes on Windows):

    cmd /c flutter run -d web-server --release --web-port 8090 --web-hostname 127.0.0.1

Android builds: keep `kotlin.incremental=false` in `android/gradle.properties` — Windows file locking corrupts Kotlin incremental caches ("Could not close incremental caches"). Never re-enable it.

## Architecture

Feature-first, layered. UI never skips layers:

    features/<f>/ui  →  logic (Cubit)  →  data (Repo)  →  ApiService (Dio)

- `lib/core/` — cross-feature code:
  - `di/dependency_injection.dart` — the ONLY place objects are registered (get_it). `registerFactory` for cubits (fresh per screen), `registerLazySingleton` for Dio/repos/storage. Adding a repo or cubit? Register it here.
  - `networking/` — all endpoints in `api_constants.dart`; only `api_service.dart`/`dio_factory.dart` touch raw Dio. Repos expose `ApiResult` (sealed, core/networking) and errors are mapped in `api_error_handler.dart` / thrown as `AppException` (core/error).
  - `routing/` — routes declared in `routes.dart`, built in `app_router.dart`.
  - `helpers/` — `secure_storage_helper` (auth tokens), `shared_pref_helper` (user data), `constants.dart`, `app_regex.dart`, `spacing.dart`.
  - `theming/` — colors/styles/font weights; use these, don't hardcode colors or text styles in screens.
- `lib/features/<feature>/` — each feature: `data/models`, `data/repos` (products also has `data/data_sources`; settings has no `data/` layer at all — it reuses LoginRepo), `logic/` (`<name>_cubit.dart` + `<name>_state.dart` sitting DIRECTLY inside `logic/` — no `cubit/` subfolder, matching the login/sign_up convention), `ui/<screen>.dart` + `ui/widgets/`.
- Cubit ONLY, in every feature (login, splash, sign_up, settings, products, product_details) — no Bloc and no event files anywhere. Actions are plain cubit methods the UI calls directly (e.g. `cubit.fetchProducts()`); `BlocBuilder`/`BlocListener`/`BlocProvider` still work with Cubits and are what the UI uses.

## Secrets & gitignore

- `.zcode/config.json` and `opencode.json` are gitignored ON PURPOSE — they contain API tokens. Never commit them, never paste their contents into code, docs, or the README.
- `.zcode/workflow-runs/` and `.zcode/workflow-drafts/` are machine-owned ZCode state, also gitignored.

## Conventions

- Imports: `package:dummyjson/...` across directories; relative imports only within the same folder.
- States and models extend Equatable.
- Search debounce is a `Timer` in the screen, NOT debounce logic in the cubit — keep cubits simple.
- Never remove the web semantics guard in `lib/main.dart`:

      if (kIsWeb) SemanticsBinding.instance.ensureSemantics();

  Flutter web renders to canvas; browser automation (Playwright/e2e) and screen readers see nothing without this.

## Project docs (read before UI/design work)

- `PRODUCT.md` — product definition: DEPI training/portfolio project, phone-first android, North Star "The Tidy Counter".
- `DESIGN.md` + `.impeccable/design.json` — design system: Confident Teal `#00796B`, Honest Green `#2E7D32`, WCAG ≥4.5:1 contrast rule, spacing scale. Follow these instead of inventing styles.

## E2E tests (sibling project)

E2E suites live in the sibling workspace `D:/flutter_p/personal_p/m/DEPI/flutter_dummyjson_auth` (additional working directory): `tests/auth.e2e.ts` + `tests/token-evidence.e2e.ts` target android, `tests/auth.web.e2e.ts` targets web. Run one suite with `npx e2e run <file> --target web` from that dir.

Gotchas:
- Android: the engine neither builds nor installs the APK — run `cmd /c flutter build apk --debug` then `adb install -r build/app/outputs/flutter-apk/app-debug.apk` first (bundleId `com.example.dummyjson`).
- Flutter-web locator quirk: `getByDisplayValue` never matches (semantics tree hides text-field values); `getByLabel`, `getByRole`, `getByText` work.
