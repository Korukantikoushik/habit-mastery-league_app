import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final bool notificationsEnabled;
  final bool darkModeEnabled;
  final String reminderTime;
  final String username;

  const SettingsState({
    required this.notificationsEnabled,
    required this.darkModeEnabled,
    required this.reminderTime,
    required this.username,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    String? reminderTime,
    String? username,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      username: username ?? this.username,
    );
  }

  static const initial = SettingsState(
    notificationsEnabled: true,
    darkModeEnabled: true,
    reminderTime: '8:00 PM',
    username: 'Student',
  );
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState.initial) {
    loadSettings();
  }

  static const _notificationsKey = 'notifications_enabled';
  static const _darkModeKey = 'dark_mode_enabled';
  static const _reminderTimeKey = 'reminder_time';
  static const _usernameKey = 'username';

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    state = SettingsState(
      notificationsEnabled:
          prefs.getBool(_notificationsKey) ??
          SettingsState.initial.notificationsEnabled,
      darkModeEnabled:
          prefs.getBool(_darkModeKey) ?? SettingsState.initial.darkModeEnabled,
      reminderTime:
          prefs.getString(_reminderTimeKey) ??
          SettingsState.initial.reminderTime,
      username: prefs.getString(_usernameKey) ?? SettingsState.initial.username,
    );
  }

  Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, value);
    state = state.copyWith(notificationsEnabled: value);
  }

  Future<void> setDarkModeEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
    state = state.copyWith(darkModeEnabled: value);
  }

  Future<void> setReminderTime(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_reminderTimeKey, value);
    state = state.copyWith(reminderTime: value);
  }

  Future<void> setUsername(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, value);
    state = state.copyWith(username: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
