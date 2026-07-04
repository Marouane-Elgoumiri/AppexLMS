/// Build-time environment selection.
///
/// Pass `--dart-define=USE_SUPABASE=false` at run/build time to fall back
/// to the in-memory mock data sources from Sprint 3 (useful for offline
/// demos and for the Sprint 4b MongoDB comparison work).
///
/// Default: `true` — the app talks to Supabase for every LMS entity.
const bool useSupabase = bool.fromEnvironment(
  'USE_SUPABASE',
  defaultValue: true,
);
