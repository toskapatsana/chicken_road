/// Presentation Layer - Settings Provider
/// 
/// Manages app settings state and persistence.

import 'package:flutter/foundation.dart';
import '../../domain/entities/app_settings.dart';
import '../../data/datasources/settings_datasource.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsDataSource _dataSource;
  
  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  SettingsProvider({SettingsDataSource? dataSource})
      : _dataSource = dataSource ?? SettingsDataSource();
  
  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _settings = await _dataSource.getSettings();
    } catch (_) {
      _settings = const AppSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> updateSettings(AppSettings newSettings) async {
    _settings = newSettings;
    notifyListeners();
    await _dataSource.saveSettings(newSettings);
  }
  
  Future<void> setMeasurementUnit(MeasurementUnit unit) async {
    await updateSettings(_settings.copyWith(measurementUnit: unit));
  }
  
  Future<void> setCookModeFontSize(CookModeFontSize size) async {
    await updateSettings(_settings.copyWith(cookModeFontSize: size));
  }
  
  Future<void> setTimerSoundEnabled(bool enabled) async {
    await updateSettings(_settings.copyWith(timerSoundEnabled: enabled));
  }
  
  Future<void> setKeepScreenOn(bool enabled) async {
    await updateSettings(_settings.copyWith(keepScreenOnInCookMode: enabled));
  }
  
  Future<void> setOnboardingCompleted(bool completed) async {
    await updateSettings(_settings.copyWith(hasCompletedOnboarding: completed));
  }
  
  Future<void> setDefaultServings(int servings) async {
    await updateSettings(_settings.copyWith(defaultServings: servings));
  }
  
  Future<void> resetSettings() async {
    await _dataSource.clearSettings();
    _settings = const AppSettings();
    notifyListeners();
  }
}
