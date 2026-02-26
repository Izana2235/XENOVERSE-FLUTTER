/// Carries which settings section to scroll to.
/// The sidebar writes [section] before calling onStateChanged(),
/// and SettingsScreen reads it in initState / didUpdateWidget.
class SettingsScrollTarget {
  static String? section;
}
