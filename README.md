# Developer Workplace

A phone-first Flutter prototype for a private developer workspace and a selectively published public portfolio.

## Run locally

```powershell
flutter pub get
flutter run
flutter analyze
flutter test
```

The private workspace opens behind a mock owner login. Use the demo passcode
`1234`; this is not real authentication and does not protect production data.

## Architecture

- `lib/core` contains app navigation, Riverpod providers, the sketchbook theme,
  reusable sketch widgets, and demo seed data.
- `lib/features` is organized by product feature with domain models,
  repository/service abstractions, local/mock implementations, and screens.
- Project and task state is stored locally through `shared_preferences`.
- The public portfolio uses separate `PublicProfile`, `PublicProject`,
  `PublicEvidence`, and `PublicContext` projections. Only projects marked
  public are eligible for projection, and each optional project field has an
  approval flag.
- Tests cover Kanban move invariants, health scoring, focus timer calculations,
  public-context serialization, and the mock owner login.

## Prototype assumptions and limits

- The owner is the fixed demo identity `owner-1`; login accepts only the
  hard-coded demo passcode `1234`.
- Repositories, GitHub activity, and AI responses are mocked. There are no
  Supabase, GitHub, or Gemini network calls.
- Preferences are local prototype persistence, not secure storage or a
  multi-device sync mechanism.
- The prototype is being completed in phases. The navigation/theme/login
  foundation is complete; domain data and persistence are the next phase to
  finish before later feature flows can be considered complete.
