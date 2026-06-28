import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/goals_provider.dart';
import '../theme/app_theme.dart';
import '../models/goal.dart';
import 'ai_chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalsProvider>();
    final goal = provider.primaryGoal;

    return Scaffold(
      backgroundColor: PathlyTheme.surfaceAlt,
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, goal),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (goal != null) _buildTodayLesson(context, goal, provider),
                const SizedBox(height: 16),
                _buildStreakRow(provider),
                const SizedBox(height: 16),
                _buildAICard(context, goal),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Goal? goal) {
    return SliverAppBar(
      expandedHeight: 140,
      pinned: true,
      backgroundColor: PathlyTheme.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          color: PathlyTheme.primary,
          padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pathly',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    child: const Icon(Icons.person_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
              if (goal != null) ...[
                const SizedBox(height: 8),
                Text(goal.title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: goal.progress,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation(Colors.white),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(goal.progress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodayLesson(BuildContext context, Goal goal, GoalsProvider provider) {
    final todayLesson = goal.lessons.isNotEmpty ? goal.lessons.first : null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: goal.lightColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, size: 12, color: goal.color),
                      const SizedBox(width: 4),
                      Text('اليوم ${goal.totalDays + 1}', style: TextStyle(color: goal.color, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (todayLesson != null) ...[
              Text(todayLesson.content, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(todayLesson.translation, style: const TextStyle(color: PathlyTheme.textMuted, fontSize: 14)),
            ] else ...[
              Text('درس اليوم', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.volume_up_rounded, size: 16),
                    label: const Text('استمع للنطق'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goal.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => provider.completeLesson(goal.id),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('أتممت'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: goal.color,
                    side: BorderSide(color: goal.color),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakRow(GoalsProvider provider) {
    return Row(
      children: [
        Expanded(child: _statCard('🔥', '${provider.primaryGoal?.currentStreak ?? 0}', 'يوم متواصل')),
        const SizedBox(width: 10),
        Expanded(child: _statCard('📚', '${provider.primaryGoal?.totalDays ?? 0}', 'درس مكتمل')),
      ],
    );
  }

  Widget _statCard(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: PathlyTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: PathlyTheme.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: PathlyTheme.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 11, color: PathlyTheme.textMuted)),
        ],
      ),
    );
  }

  Widget _buildAICard(BuildContext context, Goal? goal) {
    return GestureDetector(
      onTap: () {
        if (goal != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => AIChatScreen(goal: goal)));
        }
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: PathlyTheme.primaryLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFC4B5FD), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PathlyTheme.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('مساعد AI', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF3C3489))),
                  SizedBox(height: 2),
                  Text('ابدأ محادثة تدريبية الآن', style: TextStyle(fontSize: 12, color: Color(0xFF5B21B6))),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF7C3AED)),
          ],
        ),
      ),
    );
  }
}
