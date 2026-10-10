import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;

  int get currentIndex => _currentIndex;

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

