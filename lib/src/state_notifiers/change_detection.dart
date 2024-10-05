import 'package:domino/domino.dart' as domino show DomView, DomEvent;

/// Controls the unique root view automatic re-render.
final changeDetection = ChangeDetection();

class ChangeDetection {
  final listeners = <domino.DomView>{};

  // Enabled by default.
  var _enabled = true;

  /// Checks whether change detection is enabled.
  bool get isEnabled => _enabled;

  void addListener(domino.DomView listener) {
    listeners.add(listener);
  }

  /// Re-enable change detection.
  void enable() => _enabled = true;

  /// Temporarily or permanently disable change detection for the current
  /// page.
  void disable() => _enabled = false;

  /// Request an update to the view.
  void trigger() {
    if (isEnabled) {
      for (var rootView in listeners) {
        rootView.invalidate();
      }
    }
  }

  /// Called after an event callback executes.
  void postEvent(domino.DomEvent event) {
    // We can have debounce or other optimizations.
    trigger();
  }
}
