import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/language_provider.dart';
import '../l10n/app_strings.dart';
import '../services/notification_service.dart';
import '../services/sync_service.dart';
import '../services/goals_provider.dart';
import '../theme/app_theme.dart';
import 'team_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _enabled = false;
  TimeOfDay _time = const TimeOfDay(hour: 20, minute: 0);
  bool _loading = true;
  bool _syncBusy = false;

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

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _runSync(Future<void> Function() action) async {
    setState(() => _syncBusy = true);
    try {
      await action();
    } catch (_) {
      _snack(context.read<LanguageProvider>().s.syncError);
    } finally {
      if (mounted) setState(() => _syncBusy = false);
    }
  }

  Future<void> _signIn() => _runSync(() async {
        await SyncService.instance.signInWithGoogle();
      });

  Future<void> _signOut() => _runSync(() async {
        await SyncService.instance.signOut();
      });

  Future<void> _upload() => _runSync(() async {
        final s = context.read<LanguageProvider>().s;
        final goals = context.read<GoalsProvider>().goals;
        await SyncService.instance.uploadGoals(goals);
        _snack(s.uploaded);
      });

  Future<void> _download() => _runSync(() async {
        final s = context.read<LanguageProvider>().s;
        final goals = await SyncService.instance.downloadGoals();
        if (goals == null || goals.isEmpty) {
          _snack(s.downloadEmpty);
          return;
        }
        context.read<GoalsProvider>().replaceAll(goals);
        _snack(s.downloaded);
      });

  Widget _buildSyncSection(AppStrings s) {
    final sync = SyncService.instance;

    if (!sync.firebaseReady) {
      return Card(
        child: ListTile(
          leading: const Icon(Icons.cloud_off_rounded, color: PathlyTheme.textMuted),
          title: Text(s.cloudSync,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          subtitle: Text(s.syncNotConfigured,
              style: const TextStyle(fontSize: 12, color: PathlyTheme.textMuted)),
        ),
      );
    }

    if (!sync.isSignedIn) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.cloudSyncDesc,
                  style: const TextStyle(fontSize: 13, color: PathlyTheme.textSecondary)),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _syncBusy ? null : _signIn,
                icon: const Icon(Icons.login_rounded, size: 18),
                label: Text(s.signInGoogle),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PathlyTheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.cloud_done_rounded, color: PathlyTheme.success),
            title: Text('${s.signedInAs} ${sync.userEmail ?? ''}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          ),
          const Divider(height: 1, color: PathlyTheme.border),
          ListTile(
            leading: const Icon(Icons.cloud_upload_rounded, color: PathlyTheme.primary),
            title: Text(s.uploadToCloud, style: const TextStyle(fontSize: 14)),
            enabled: !_syncBusy,
            onTap: _syncBusy ? null : _upload,
          ),
          const Divider(height: 1, color: PathlyTheme.border),
          ListTile(
            leading: const Icon(Icons.cloud_download_rounded, color: PathlyTheme.primary),
            title: Text(s.downloadFromCloud, style: const TextStyle(fontSize: 14)),
            enabled: !_syncBusy,
            onTap: _syncBusy ? null : _download,
          ),
          const Divider(height: 1, color: PathlyTheme.border),
          ListTile(
            leading: const Icon(Icons.logout_rounded, color: PathlyTheme.danger),
            title: Text(s.signOut,
                style: const TextStyle(fontSize: 14, color: PathlyTheme.danger)),
            enabled: !_syncBusy,
            onTap: _syncBusy ? null : _signOut,
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: PathlyTheme.textMuted,
            letterSpacing: 0.5),
      );

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
                _sectionTitle(s.dailyReminder),
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
                const SizedBox(height: 20),
                _sectionTitle(s.cloudSync),
                const SizedBox(height: 8),
                _buildSyncSection(s),
                const SizedBox(height: 20),
                _sectionTitle(s.team),
                const SizedBox(height: 8),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.groups_rounded, color: PathlyTheme.primary),
                    title: Text(s.team,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text(s.teamDesc,
                        style: const TextStyle(fontSize: 12, color: PathlyTheme.textMuted)),
                    trailing: const Icon(Icons.chevron_right_rounded, color: PathlyTheme.textMuted),
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const TeamScreen())),
                  ),
                ),
              ],
            ),
    );
  }
}
