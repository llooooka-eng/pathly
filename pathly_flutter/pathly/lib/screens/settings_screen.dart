import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/language_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final enabled = await NotificationService.instance.isEnabled();
    final time = await NotificationService.instance.savedTime();
    if (!mounted) return;
    setState(() {
      _enabled = enabled;
      _time = time;
      _loading = false;
    });
  }

  Future<void> _toggle(bool value) async {
    final s = context.read<LanguageProvider>().s;
    if (value) {
      final granted = await NotificationService.instance.requestPermissions();
      if (!granted) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.permissionDenied),
            behavior: SnackBarBehavior.floating,
            backgroundColor: PathlyTheme.danger,
          ),
        );
        return;
      }
      await NotificationService.instance.scheduleDailyReminder(
        _time,
        title: s.reminderTitle,
        body: s.reminderBody,
      );
    } else {
      await NotificationService.instance.cancelReminder();
    }
    if (!mounted) return;
    setState(() => _enabled = value);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked == null) return;
    setState(() => _time = picked);
    if (_enabled) {
      final s = context.read<LanguageProvider>().s;
      await NotificationService.instance.scheduleDailyReminder(
        picked,
        title: s.reminderTitle,
        body: s.reminderBody,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().s;

    return Scaffold(
      backgroundColor: PathlyTheme.surfaceAlt,
      appBar: AppBar(
        backgroundColor: PathlyTheme.primary,
        title: Text(s.settings,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(s.dailyReminder.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: PathlyTheme.textMuted,
                        letterSpacing: 0.5)),
                const SizedBox(height: 8),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        value: _enabled,
                        onChanged: _toggle,
                        activeColor: PathlyTheme.primary,
                        title: Text(s.dailyReminder,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        subtitle: Text(s.dailyReminderDesc,
                            style: const TextStyle(
                                fontSize: 12, color: PathlyTheme.textMuted)),
                        secondary: const Icon(Icons.notifications_active_rounded,
                            color: PathlyTheme.primary),
                      ),
                      const Divider(height: 1, color: PathlyTheme.border),
                      ListTile(
                        enabled: _enabled,
                        leading: const Icon(Icons.schedule_rounded,
                            color: PathlyTheme.primary),
                        title: Text(s.reminderTime,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500)),
                        trailing: Text(
                          _time.format(context),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: _enabled
                                ? PathlyTheme.primary
                                : PathlyTheme.textMuted,
                          ),
                        ),
                        onTap: _enabled ? _pickTime : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
