import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  TimeOfDay _lightModeStart = const TimeOfDay(
    hour: 6,
    minute: 0,
  ); // default 6:00 AM
  TimeOfDay _lightModeEnd = const TimeOfDay(
    hour: 18,
    minute: 0,
  ); // default 6:00 PM

  bool get isDarkMode => _isDarkMode;
  TimeOfDay get lightModeStart => _lightModeStart;
  TimeOfDay get lightModeEnd => _lightModeEnd;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleDarkMode() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void updateSchedule(TimeOfDay start, TimeOfDay end) {
    _lightModeStart = start;
    _lightModeEnd = end;
    notifyListeners();
  }

  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.teal,
      foregroundColor: Colors.white,
    ),
  );

  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.teal,
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
  );
}
