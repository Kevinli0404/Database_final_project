import 'package:flutter/material.dart';

class SharedState with ChangeNotifier {
  bool _buttonsDrawed = true;
  int _currentIndex = 0;
  // bottomNavigationBar 按鈕失效
  bool _buttonsDisabled = false;

  bool get buttonsDrawed => _buttonsDrawed;
  int get currentIndex => _currentIndex;
  bool get buttonsDisabled => _buttonsDisabled;

  // void toggleDrawed() {
  //   _isDrawed = !_isDrawed;
  //   notifyListeners();
  // }

  void toggleDrawed(bool value) {
    _buttonsDrawed = value;
    notifyListeners();
  }

  void updateCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setButtonsDisabled(bool value) {
    _buttonsDisabled = value;
    notifyListeners();
  }
}
