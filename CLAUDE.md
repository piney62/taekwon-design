# TulMaster — Project Context for Claude

## Repository layout

```
ITF_Client/   Flutter app (real app — functional backend, ML, auth)
ITF_Server/   FastAPI + asyncpg + PostgreSQL backend
app/          Flutter design prototype (reference only — do not ship)
```

## Primary goal

Apply the design system from `app/` onto `ITF_Client/` without breaking any existing functionality.
Migration is phase-based; see **Phase status** below.

---

## Tech stack

| Layer | Detail |
|---|---|
| Flutter | 3.41 / Dart 3.11.5 |
| State | Riverpod 2.6.1 |
| Navigation | go_router 14.6.2 — `StatefulShellRoute.indexedStack` (5 tabs) |
| i18n | easy_localization |
| Backend | FastAPI + asyncpg + PostgreSQL |
| ML | MediaPipe Tasks (server-side pose detection) |

---

## Navigation structure

```
GoRouter root
├── /register  → RegisterScreen          (outside shell)
├── /coach     → CoachScreen             (outside shell — NO tab bar)
├── /settings  → SettingsScreen          (outside shell)
└── StatefulShellRoute (AppShell)
    ├── /home        → HomeScreen
    ├── /analyze     → PoseAnalysisScreen
    ├── /journal     → JournalScreen | InstructorDojoScreen (by role)
    ├── /learn       → LearnScreen
    └── /stats       → SettingsScreen (StatsScreen orphaned — re-wire in Phase 3-10)
```

Sub-screens pushed via `Navigator.push` from within a shell branch **stay inside the shell** — the floating tab bar is still visible over them.

---

## Key design decisions

### Tab bar (`AppShell`)
- `extendBody: true` — body draws under the floating tab bar
- `BackdropFilter(blur: 20)` for frosted-glass effect
- `palette.tabbarBg`: dark `0xC70A0A0C` (78 % alpha), light `0xCCFFFFFF` (80 % alpha)
- `kAppShellContentBottomInset = 96` — exported constant from `shared/widgets/app_shell.dart`

### Bottom-inset rule
**Every scrollable screen or sub-screen that is rendered inside the shell body must reserve `kAppShellContentBottomInset` at the very bottom of its content**, so the last item isn't hidden behind the tab bar. Fixed-bottom bars (e.g. comment input) must push themselves up by the same amount.

`CoachScreen` is a top-level route (outside the shell) — no bottom inset needed there.

### TulPalette
Theme-aware color extension — access via `context.tul`. Defined in `core/theme/tul_palette.dart`. Dark and light static instances (`TulPalette.dark` / `.light`) are registered in `app_theme.dart`.

### TulGradients
- `TulGradients.brand` — main gradient (AppColors.gradMain)
- `TulGradients.feature` — wine variant: `#B91C1C → #7E22CE → #1E40AF` (use for FeatureCard, never the candy red-pink-blue brand gradient)

### Feature card halo
`BoxShadow(color: Color(0x33B91C1C), blurRadius: 50, offset: Offset(0, 18))` — in `TulShadows.featureDark`

---

## Phase status

| Phase | Description | State |
|---|---|---|
| 0 | Baseline — zero errors, web build passes | ✅ done |
| 1 | Design tokens (tul_palette, tul_gradients, tul_shadows, tul_radius, tul_text_styles) | ✅ done |
| 2 | Port 16 tul_* shared widgets (add-only, zero UI change) | ✅ done |
| 3-1 | AppShell tab bar redesign + kAppShellContentBottomInset on **all** screens | ✅ done |
| 3-2 | Redesign Student HomeScreen (FeatureCard + StatCard) | ✅ done |
| 3-3 | Redesign Instructor HomeScreen | 🔲 next |
| 3-4 | Register flow redesign + splash + welcome with logo | 🔲 |
| 3-5 | Journal screen + sheets/details | 🔲 |
| 3-6 | InstructorDojo + StudentDetail | 🔲 |
| 3-7 | Learn + PatternDetail + Terminology / Tenets / History | 🔲 |
| 3-8 | CoachScreen (chat bubbles + composer) | 🔲 |
| 3-9 | PoseAnalysisScreen (UI shell only, ML untouched) | 🔲 |
| 3-10 | Settings + re-wire StatsScreen | 🔲 |
| 4 | Polish — logo, i18n keys, dark/light QA | 🔲 |

---

## Screens that already use kAppShellContentBottomInset

All screens below have been updated. Do not regress them.

```
home_screen.dart              student CustomScrollView tail + instructor ListView padding
journal_screen.dart           SliverToBoxAdapter tail
pose_analysis_screen.dart     SizedBox tail
settings_screen.dart          SizedBox tail
learn_screen.dart             SliverToBoxAdapter tail
instructor_dojo_screen.dart   SizedBox tail
student_detail_screen.dart    _JournalTab, _HomeworkTab (ListView padding)
                              _CommentsTab (input container bottom padding)
all_sessions_screen.dart      ListView padding bottom
readiness_detail_screen.dart  inner Padding bottom (clears theory button)
weakness_detail_screen.dart   ListView padding bottom
patterns_page.dart            ListView.separated padding bottom
terminology_page.dart         ListView.separated padding bottom
five_tenets_page.dart         ListView.separated padding bottom
history_page.dart             ListView.builder padding bottom
stats_screen.dart             _StudentStats + _InstructorStatsBody tail SizedBox
```

---

## Assets

- `assets/images/logo_white.png` — white logo for dark backgrounds (splash, welcome)

---

## Server startup

```powershell
cd ITF_Server
venv\Scripts\Activate.ps1
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

Key env vars in `ITF_Server/.env`: `DATABASE_URL`, `SECRET_KEY`, `OPENAI_API_KEY`.
