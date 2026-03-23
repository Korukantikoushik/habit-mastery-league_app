import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/notification_service.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _nameController;

  final List<String> _timeOptions = const [
    '6:00 AM',
    '7:00 AM',
    '8:00 AM',
    '9:00 AM',
    '6:00 PM',
    '7:00 PM',
    '8:00 PM',
    '9:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    _nameController = TextEditingController(text: settings.username);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.06),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.08),
          blurRadius: 10,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Color _primaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color _secondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : Colors.black54;
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final themeNotifier = ref.read(themeProvider.notifier);
    final isDarkTheme = ref.watch(themeProvider) == ThemeMode.dark;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_nameController.text != settings.username) {
      _nameController.text = settings.username;
      _nameController.selection = TextSelection.fromPosition(
        TextPosition(offset: _nameController.text.length),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF0F1020), Color(0xFF17192E), Color(0xFF23264B)]
              : const [Color(0xFFF7F9FF), Color(0xFFEAF0FF), Color(0xFFDEE7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Settings',
            style: TextStyle(color: _primaryText(context)),
          ),
          iconTheme: IconThemeData(color: _primaryText(context)),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C5CFA), Color(0xFF5B8DEF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preferences',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Customize your habit\nexperience',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: TextStyle(
                      color: _primaryText(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(color: _primaryText(context)),
                    decoration: InputDecoration(
                      labelText: 'Display name',
                      labelStyle: TextStyle(color: _secondaryText(context)),
                      hintText: 'Enter your name',
                      hintStyle: TextStyle(color: _secondaryText(context)),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF4F6FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) async {
                      final trimmed = value.trim();
                      if (trimmed.isNotEmpty) {
                        await notifier.setUsername(trimmed);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Display name updated')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                children: [
                  SwitchListTile(
                    value: settings.notificationsEnabled,
                    onChanged: notifier.setNotificationsEnabled,
                    activeThumbColor: const Color(0xFF7C5CFA),
                    title: Text(
                      'Enable notifications',
                      style: TextStyle(color: _primaryText(context)),
                    ),
                    subtitle: Text(
                      'Daily reminders for your habits',
                      style: TextStyle(color: _secondaryText(context)),
                    ),
                  ),
                  Divider(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.08),
                    height: 8,
                  ),
                  SwitchListTile(
                    value: isDarkTheme,
                    onChanged: (value) async {
                      await notifier.setDarkModeEnabled(value);
                      await themeNotifier.toggleTheme(value);
                    },
                    activeThumbColor: const Color(0xFF7C5CFA),
                    title: Text(
                      'Dark mode',
                      style: TextStyle(color: _primaryText(context)),
                    ),
                    subtitle: Text(
                      'Keep the app in dark theme',
                      style: TextStyle(color: _secondaryText(context)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reminder Time',
                    style: TextStyle(
                      color: _primaryText(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _timeOptions.contains(settings.reminderTime)
                        ? settings.reminderTime
                        : _timeOptions.first,
                    dropdownColor: isDark
                        ? const Color(0xFF1E2238)
                        : Colors.white,
                    style: TextStyle(color: _primaryText(context)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : const Color(0xFFF4F6FB),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _timeOptions
                        .map(
                          (time) => DropdownMenuItem<String>(
                            value: time,
                            child: Text(time),
                          ),
                        )
                        .toList(),
                    onChanged: (value) async {
                      if (value != null) {
                        await notifier.setReminderTime(value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (!settings.notificationsEnabled) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Enable notifications first in settings',
                            ),
                          ),
                        );
                        return;
                      }

                      await NotificationService.instance.showSimpleReminder(
                        title: 'Habit Reminder',
                        body:
                            'Hi ${settings.username}, time to complete your daily habits at ${settings.reminderTime}.',
                      );

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Test reminder sent')),
                      );
                    },
                    icon: const Icon(Icons.notifications_active_outlined),
                    label: const Text('Send Test Notification'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: _cardDecoration(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Settings',
                    style: TextStyle(
                      color: _primaryText(context),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _SettingRow(
                    label: 'User',
                    value: settings.username,
                    isDark: isDark,
                  ),
                  _SettingRow(
                    label: 'Notifications',
                    value: settings.notificationsEnabled
                        ? 'Enabled'
                        : 'Disabled',
                    isDark: isDark,
                  ),
                  _SettingRow(
                    label: 'Theme',
                    value: isDarkTheme ? 'Dark' : 'Light',
                    isDark: isDark,
                  ),
                  _SettingRow(
                    label: 'Reminder',
                    value: settings.reminderTime,
                    isDark: isDark,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;

  const _SettingRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.08),
                ),
              ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
