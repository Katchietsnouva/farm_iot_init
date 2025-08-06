// lib/utils/screen_type.dart
import 'package:flutter/material.dart';

enum ScreenType { mobile, tablet, desktop }

class ScreenTypeDetector extends InheritedWidget {
  final ScreenType screenType;

  ScreenTypeDetector({required Widget child, required this.screenType})
    : super(child: child);

  static ScreenType of(BuildContext context) {
    final detector =
        context.dependOnInheritedWidgetOfExactType<ScreenTypeDetector>();
    if (detector == null) {
      throw FlutterError('No ScreenTypeDetector found in context');
    }
    return detector.screenType;
  }

  @override
  bool updateShouldNotify(ScreenTypeDetector oldWidget) {
    return screenType != oldWidget.screenType;
  }
}
