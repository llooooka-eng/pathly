import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:share_plus/share_plus.dart';
import '../services/goals_provider.dart';
import '../l10n/language_provider.dart';
import '../l10n/app_strings.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _shareProgress(BuildContext context, GoalsProvider provider) {
    final s = context.read<LanguageProvider>().s;
    final goal = provider.primaryGoal;
    if (goal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.shareNoData), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    Share.share(_buildShareText(s, goal), subject: s.shareHeadline);
  }

  String _buildShareText(AppStrings s, Goal goal) {
    final pct = (goal.progress * 100).toStringAsFixed(0);
    return '${s.shareHeadline}\n\n'
        '${goal.title} — $pct%\n'
        '${goal.currentStreak} ${s.dayStreak} 🔥\n\n'
        '${s.appTagline} — Pathly';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalsProvider>();

    return Scaffold(
      backgroundColor: PathlyTheme.surfaceAlt,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 100,
            backgroundColor: PathlyTheme.primary,
            actions: [
              IconButton(
                tooltip: context.read<LanguageProvider>().s.shareProgress,
                icon: const Icon(Icons.share_rounded, color: Colors.white),
                onPressed: () => _shareProgress(context, provider),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: PathlyTheme.primary,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text('تقدمي', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          Text('الأسبوع الثاني عشر',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                      child: const Text('على المسار ✓', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildStatsGrid(provider),
                const SizedBox(height: 16),
                _buildWeeklyChart(),
                const SizedBox(height: 16),
                _buildGoalsProgress(provider),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(GoalsProvider provider) {
    final goal = provider.primaryGoal;
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.6,
      children: [
        _statBox('🔥', '${goal?.currentStreak ?? 0}', 'يوم streak'),
        _statBox('📚', '${goal?.totalDays ?? 0}', 'درس مكتمل'),
        _statBox('📊', '${((goal?.progress ?? 0) * 100).toStringAsFixed(0)}%', 'من الهدف'),
        _statBox('⏱', '18 د', 'متوسط يومي'),
      ],
    );
  }

  Widget _statBox(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: PathlyTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PathlyTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: PathlyTheme.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 11, color: PathlyTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final data = [24.0, 18.0, 30.0, 12.0, 21.0, 27.0, 15.0];
    final days = ['إث', 'ثل', 'أر', 'خم', 'جم', 'سب', 'أح'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نشاط الأسبوع', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 14),
            SizedBox(
              height: 140,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 35,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final i = value.toInt();
                          if (i < 0 || i >= days.length) return const SizedBox();
                          return Text(days[i], style: const TextStyle(fontSize: 11, color: PathlyTheme.textMuted));
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(7, (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i],
                        color: i == 5 ? PathlyTheme.primary : PathlyTheme.primaryLight,
                        width: 24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsProgress(GoalsProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('تقدم الأهداف', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            ...provider.goals.map((g) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(g.icon, size: 14, color: g.color),
                          const SizedBox(width: 6),
                          Text(g.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                        ],
                      ),
                      Text('${(g.progress * 100).toStringAsFixed(0)}%', style: TextStyle(fontSize: 12, color: g.color, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: g.progress,
                      backgroundColor: PathlyTheme.border,
                      valueColor: AlwaysStoppedAnimation(g.color),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}
