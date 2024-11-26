import 'package:flutter/material.dart';

class NavigationState {
  static final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);

  static void updateIndex(int index) {
    selectedIndex.value = index;
  }
}