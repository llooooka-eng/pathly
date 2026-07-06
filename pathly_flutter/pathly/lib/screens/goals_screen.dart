import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/goals_provider.dart';
import '../models/goal.dart';
import '../l10n/language_provider.dart';
import '../theme/app_theme.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: PathlyTheme.primary,
                padding: const EdgeInsets.fromLTRB(20, 60, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text('أهدافي', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600)),
                    SizedBox(height: 2),
                    Text('اختر ما تريد تطويره', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionTitle('أهدافك الحالية'),
                const SizedBox(height: 8),
                ...provider.goals.map((g) => _buildGoalTile(context, g, provider)),
                const SizedBox(height: 16),
                _buildSectionTitle('أضف هدفاً جديداً'),
                const SizedBox(height: 8),
                if (!provider.canAddGoal)
                  _buildProBanner(context, provider),
                if (provider.canAddGoal) ...[
                  _buildCustomGoalTile(context, provider),
                  const SizedBox(height: 8),
                  Card(
                    child: Column(
                      children: GoalTemplate.all
                          .where((t) => !provider.goals.any((g) => g.category == t.category))
                          .map((t) => _buildTemplateTile(context, t, provider))
                          .toList(),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: PathlyTheme.textMuted, letterSpacing: 0.5),
    );
  }

  Widget _buildGoalTile(BuildContext context, Goal goal, GoalsProvider provider) {
    final s = context.read<LanguageProvider>().s;
    return Dismissible(
      key: ValueKey(goal.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerEnd,
        decoration: BoxDecoration(
          color: PathlyTheme.dangerLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: PathlyTheme.danger),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(s.deleteGoal),
                content: Text(s.deleteGoalConfirm),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: Text(s.cancel),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    style: TextButton.styleFrom(foregroundColor: PathlyTheme.danger),
                    child: Text(s.delete),
                  ),
                ],
              ),
            ) ??
            false;
      },
      onDismissed: (_) {
        provider.deleteGoal(goal.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(s.goalDeleted),
            backgroundColor: PathlyTheme.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: goal.lightColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(goal.icon, color: goal.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(goal.title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('يوم ${goal.currentStreak}', style: const TextStyle(fontSize: 11, color: PathlyTheme.textMuted)),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: goal.progress,
                        backgroundColor: PathlyTheme.border,
                        valueColor: AlwaysStoppedAnimation(goal.color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${(goal.progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(color: goal.color, fontWeight: FontWeight.w500, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomGoalTile(BuildContext context, GoalsProvider provider) {
    final s = context.read<LanguageProvider>().s;
    return Card(
      child: ListTile(
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: PathlyTheme.primaryLight, borderRadius: BorderRadius.circular(8)),
          child: const Icon(Icons.add_rounded, color: PathlyTheme.primary, size: 20),
        ),
        title: Text(s.customGoal, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        subtitle: Text(s.customGoalDesc, style: const TextStyle(fontSize: 11, color: PathlyTheme.textMuted)),
        trailing: const Icon(Icons.chevron_right_rounded, color: PathlyTheme.textMuted),
        onTap: () => _showCustomGoalSheet(context, provider),
      ),
    );
  }

  void _showCustomGoalSheet(BuildContext context, GoalsProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PathlyTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _CustomGoalSheet(provider: provider),
    );
  }

  Widget _buildTemplateTile(BuildContext context, GoalTemplate template, GoalsProvider provider) {
    final goal = Goal(
      id: '',
      title: template.title,
      category: template.category,
      description: template.description,
      startDate: DateTime.now(),
      targetDate: DateTime.now().add(Duration(days: template.durationDays)),
    );
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: goal.lightColor, borderRadius: BorderRadius.circular(8)),
        child: Icon(goal.icon, color: goal.color, size: 18),
      ),
      title: Text(template.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
      subtitle: Text(template.description, style: const TextStyle(fontSize: 11, color: PathlyTheme.textMuted)),
      trailing: Icon(Icons.add_circle_outline_rounded, color: PathlyTheme.primary),
      onTap: () {
        provider.addGoal(template);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تمت إضافة "${template.title}"'),
            backgroundColor: PathlyTheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      },
    );
  }

  Widget _buildProBanner(BuildContext context, GoalsProvider provider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PathlyTheme.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC4B5FD)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lock_rounded, color: Color(0xFF5B21B6), size: 16),
              SizedBox(width: 6),
              Text('ميزة Pro', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF3C3489))),
            ],
          ),
          const SizedBox(height: 6),
          const Text('أهداف غير محدودة متاحة في الخطة Pro', style: TextStyle(fontSize: 12, color: Color(0xFF5B21B6))),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => provider.upgradeToPro(),
            style: ElevatedButton.styleFrom(
              backgroundColor: PathlyTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('ترقّ إلى Pro — \$7 / شهر', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ─── Bottom sheet: إنشاء هدف مخصص ──────────────────────────────────────────
class _CustomGoalSheet extends StatefulWidget {
  final GoalsProvider provider;
  const _CustomGoalSheet({required this.provider});

  @override
  State<_CustomGoalSheet> createState() => _CustomGoalSheetState();
}

class _CustomGoalSheetState extends State<_CustomGoalSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _daysController = TextEditingController(text: '90');
  GoalCategory _category = GoalCategory.custom;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _daysController.dispose();
    super.dispose();
  }

  void _submit() {
    final s = context.read<LanguageProvider>().s;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(s.goalTitleRequired), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    final days = int.tryParse(_daysController.text.trim()) ?? 90;
    widget.provider.addCustomGoal(
      title: title,
      category: _category,
      description: _descController.text.trim(),
      durationDays: days < 1 ? 1 : days,
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة "$title"'),
        backgroundColor: PathlyTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LanguageProvider>().s;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: PathlyTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(s.customGoal,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: PathlyTheme.textPrimary)),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: s.goalTitle,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            decoration: InputDecoration(
              labelText: s.goalDescription,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 16),
          Text(s.category, style: const TextStyle(fontSize: 12, color: PathlyTheme.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GoalCategory.values.map((c) {
              final sample = Goal(
                id: '',
                title: '',
                category: c,
                description: '',
                startDate: DateTime.now(),
                targetDate: DateTime.now(),
              );
              final selected = _category == c;
              return ChoiceChip(
                selected: selected,
                onSelected: (_) => setState(() => _category = c),
                avatar: Icon(sample.icon, size: 16, color: selected ? Colors.white : sample.color),
                label: Text(sample.categoryLabel),
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: selected ? Colors.white : PathlyTheme.textPrimary,
                ),
                selectedColor: PathlyTheme.primary,
                backgroundColor: PathlyTheme.surfaceAlt,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _daysController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: s.durationDays,
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: PathlyTheme.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 46),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(s.create, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
