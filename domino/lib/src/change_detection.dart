import '../browser.dart';

class ChangeDetection {
  bool _enabled = true;

  bool get isEnabled => _enabled;

  void postEvent(DomEvent event) {
    trigger();
  }

  void trigger() {
    if (isEnabled) {
      // We can have debounce or other optimizations.
      rootView.invalidate();
    }
  }

  void enable() => _enabled = true;

  void disable() => _enabled = false;
}
