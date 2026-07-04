/// `Unit` is a stand-in for "nothing meaningful" (similar to Kotlin's Unit /
/// Haskell's `()`). Used as the success type of use cases that don't return a
/// value (e.g. logout).
class Unit {
  const Unit._();
  static const Unit instance = Unit._();
}
