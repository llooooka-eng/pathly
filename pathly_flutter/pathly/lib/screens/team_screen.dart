import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../l10n/language_provider.dart';
import '../l10n/app_strings.dart';
import '../models/team.dart';
import '../services/goals_provider.dart';
import '../services/sync_service.dart';
import '../services/team_service.dart';
import '../theme/app_theme.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  Team? _team;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  int get _streak => context.read<GoalsProvider>().totalStreak;
  int get _goalsCount => context.read<GoalsProvider>().goals.length;

  Future<void> _load() async {
    // حدّث إحصائياتي أولاً إن كنت في فريق، ثم اجلب الفريق.
    await TeamService.instance.pushMyStats(streak: _streak, goals: _goalsCount);
    final team = await TeamService.instance.getMyTeam();
    if (!mounted) return;
    setState(() {
      _team = team;
      _loading = false;
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (_) {
      _snack(context.read<LanguageProvider>().s.syncError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _create() => _run(() async {
        final s = context.read<LanguageProvider>().s;
        final name = _nameController.text.trim();
        if (name.isEmpty) {
          _snack(s.teamNameRequired);
          return;
        }
        await TeamService.instance
            .createTeam(name, streak: _streak, goals: _goalsCount);
        _snack(s.teamCreated);
        await _reload();
      });

  Future<void> _join() => _run(() async {
        final s = context.read<LanguageProvider>().s;
        final code = _codeController.text.trim();
        if (code.isEmpty) return;
        final ok = await TeamService.instance
            .joinTeam(code, streak: _streak, goals: _goalsCount);
        _snack(ok ? s.joinedTeam : s.teamNotFound);
        if (ok) await _reload();
      });

  Future<void> _leave() => _run(() async {
        final s = context.read<LanguageProvider>().s;
        await TeamService.instance.leaveTeam();
        _snack(s.leftTeam);
        await _reload();
      });

  Future<void> _reload() async {
    final team = await TeamService.instance.getMyTeam();
    if (!mounted) return;
    setState(() => _team = team);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().s;

    return Scaffold(
      backgroundColor: PathlyTheme.surfaceAlt,
      appBar: AppBar(
        backgroundColor: PathlyTheme.primary,
        title: Text(s.team,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(s),
    );
  }

  Widget _buildBody(AppStrings s) {
    final sync = SyncService.instance;
    if (!sync.firebaseReady) {
      return _centerHint(Icons.cloud_off_rounded, s.syncNotConfigured);
    }
    if (!sync.isSignedIn) {
      return _centerHint(Icons.group_rounded, s.teamSignInHint);
    }
    if (_team == null) return _buildNoTeam(s);
    return _buildTeam(s, _team!);
  }

  Widget _centerHint(IconData icon, String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: PathlyTheme.textMuted),
            const SizedBox(height: 12),
            Text(text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: PathlyTheme.textMuted)),
          ],
        ),
      ),
    );
  }

  Widget _buildNoTeam(AppStrings s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(s.teamDesc,
            style: const TextStyle(fontSize: 13, color: PathlyTheme.textSecondary)),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.createTeam,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: s.teamName,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _busy ? null : _create,
                  style: _primaryBtn(),
                  child: Text(s.createTeam),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s.joinTeam,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
                TextField(
                  controller: _codeController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    labelText: s.enterInviteCode,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _busy ? null : _join,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PathlyTheme.primary,
                    side: const BorderSide(color: PathlyTheme.primary),
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(s.joinTeam),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeam(AppStrings s, Team team) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.groups_rounded, color: PathlyTheme.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(team.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text('${s.inviteCode}: ',
                        style: const TextStyle(fontSize: 13, color: PathlyTheme.textMuted)),
                    SelectableText(team.code,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            color: PathlyTheme.primary)),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.share_rounded, color: PathlyTheme.primary),
                      onPressed: () => Share.share(
                          '${s.joinTeam} "${team.name}" — ${s.inviteCode}: ${team.code}'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(s.teamMembers.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: PathlyTheme.textMuted,
                letterSpacing: 0.5)),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              for (int i = 0; i < team.leaderboard.length; i++)
                _memberTile(i, team.leaderboard[i]),
            ],
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: _busy ? null : _leave,
          icon: const Icon(Icons.logout_rounded, color: PathlyTheme.danger),
          label: Text(s.leaveTeam, style: const TextStyle(color: PathlyTheme.danger)),
        ),
      ],
    );
  }

  Widget _memberTile(int rank, TeamMember m) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: PathlyTheme.primaryLight,
        child: Text('${rank + 1}',
            style: const TextStyle(color: PathlyTheme.primary, fontWeight: FontWeight.w600)),
      ),
      title: Text(m.email.isEmpty ? '—' : m.email,
          style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
      trailing: Text('🔥 ${m.streak}   🎯 ${m.goals}',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  ButtonStyle _primaryBtn() => ElevatedButton.styleFrom(
        backgroundColor: PathlyTheme.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      );
}
