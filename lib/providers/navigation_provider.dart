import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Manages the active bottom-navigation tab index across the app.
///
/// **Purpose:**
/// Keeps track of which main screen (`0 = Home`, `1 = Events`, `2 = Profile`)
/// is currently selected so the bottom bar, side drawer, and body stay in sync.
///
/// **How it works:**
/// Extends [ChangeNotifier] from Flutter's foundation library. When [setTab] is
/// called, it updates `_currentIndex` and calls [notifyListeners], which tells
/// any widget watching [NavigationProvider] to rebuild with the new tab.
class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  /// The index of the currently active bottom navigation tab (`0` to `2`).
  int get currentIndex => _currentIndex;

  /// Switches the active bottom navigation tab to [index].
  ///
  /// **Purpose:**
  /// Allows any widget (such as the bottom bar, side drawer, or "See All"
  /// buttons on the Home screen) to switch tabs programmatically.
  ///
  /// **How it works:**
  /// 1. Clamps [index] between `0` and `2` to prevent out-of-range errors.
  /// 2. Returns early if the requested tab is already selected (avoiding
  ///    unnecessary UI rebuilds).
  /// 3. Checks [SchedulerBinding.schedulerPhase] before calling
  ///    [notifyListeners] so notifications never fire mid-frame during a build.
  void setTab(int index) {
    final target = index.clamp(0, 2);
    if (_currentIndex == target) return;
    _currentIndex = target;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } else {
      notifyListeners();
    }
  }
}

