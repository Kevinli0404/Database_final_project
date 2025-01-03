import 'package:flutter/material.dart';

class SharedState with ChangeNotifier {
  bool _isDrawed = false;
  int _currentIndex = 0;

  bool get isDrawed => _isDrawed;
  int get currentIndex => _currentIndex;

  void toggleDrawed() {
    _isDrawed = !_isDrawed;
    notifyListeners();
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}
