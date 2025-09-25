import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveTheme();
    notifyListeners();
  }
  
  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;
  
  static final _lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
    brightness: Brightness.light,
  );
  
  static final _darkTheme = ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
    brightness: Brightness.dark,
  );
  
  Future<void> _loadTheme() async {
    final box = await Hive.openBox('settings');
    _isDarkMode = box.get('isDarkMode', defaultValue: false);
    notifyListeners();
  }
  
  Future<void> _saveTheme() async {
    final box = await Hive.openBox('settings');
    await box.put('isDarkMode', _isDarkMode);
  }
}