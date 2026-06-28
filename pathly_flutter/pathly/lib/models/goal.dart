import 'package:flutter/material.dart';

enum GoalCategory {
  language,
  fitness,
  design,
  reading,
  coding,
  custom,
}

class Goal {
  final String id;
  final String title;
  final GoalCategory category;
  final String description;
  final DateTime startDate;
  final DateTime targetDate;
  final int currentStreak;
  final int totalDays;
  final double progress;
  final List<DailyLesson> lessons;
  final bool isPro;

  Goal({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.startDate,
    required this.targetDate,
    this.currentStreak = 0,
    this.totalDays = 0,
    this.progress = 0.0,
    this.lessons = const [],
    this.isPro = false,
  });

  IconData get icon {
    switch (category) {
      case GoalCategory.language: return Icons.language_rounded;
      case GoalCategory.fitness:  return Icons.directions_run_rounded;
      case GoalCategory.design:   return Icons.palette_rounded;
      case GoalCategory.reading:  return Icons.menu_book_rounded;
      case GoalCategory.coding:   return Icons.code_rounded;
      case GoalCategory.custom:   return Icons.star_rounded;
    }
  }

  Color get color {
    switch (category) {
      case GoalCategory.language: return const Color(0xFF7C3AED);
      case GoalCategory.fitness:  return const Color(0xFF059669);
      case GoalCategory.design:   return const Color(0xFFD97706);
      case GoalCategory.reading:  return const Color(0xFFDC2626);
      case GoalCategory.coding:   return const Color(0xFF2563EB);
      case GoalCategory.custom:   return const Color(0xFF7C3AED);
    }
  }

  Color get lightColor {
    switch (category) {
      case GoalCategory.language: return const Color(0xFFEDE9FE);
      case GoalCategory.fitness:  return const Color(0xFFD1FAE5);
      case GoalCategory.design:   return const Color(0xFFFEF3C7);
      case GoalCategory.reading:  return const Color(0xFFFEE2E2);
      case GoalCategory.coding:   return const Color(0xFFDBEAFE);
      case GoalCategory.custom:   return const Color(0xFFEDE9FE);
    }
  }

  String get categoryLabel {
    switch (category) {
      case GoalCategory.language: return 'لغة';
      case GoalCategory.fitness:  return 'لياقة';
      case GoalCategory.design:   return 'تصميم';
      case GoalCategory.reading:  return 'قراءة';
      case GoalCategory.coding:   return 'برمجة';
      case GoalCategory.custom:   return 'مخصص';
    }
  }

  Goal copyWith({double? progress, int? currentStreak, int? totalDays}) {
    return Goal(
      id: id,
      title: title,
      category: category,
      description: description,
      startDate: startDate,
      targetDate: targetDate,
      currentStreak: currentStreak ?? this.currentStreak,
      totalDays: totalDays ?? this.totalDays,
      progress: progress ?? this.progress,
      lessons: lessons,
      isPro: isPro,
    );
  }
}

class DailyLesson {
  final int day;
  final String content;
  final String translation;
  final String? audioUrl;
  final bool isCompleted;

  const DailyLesson({
    required this.day,
    required this.content,
    required this.translation,
    this.audioUrl,
    this.isCompleted = false,
  });
}

class GoalTemplate {
  final String title;
  final GoalCategory category;
  final String description;
  final int durationDays;
  final List<String> sampleLessons;

  const GoalTemplate({
    required this.title,
    required this.category,
    required this.description,
    required this.durationDays,
    required this.sampleLessons,
  });

  static const List<GoalTemplate> all = [
    GoalTemplate(
      title: 'تعلم الإسبانية',
      category: GoalCategory.language,
      description: 'جملة يومية أساسية حتى الطلاقة',
      durationDays: 365,
      sampleLessons: ['¿Cómo estás?', '¿Cómo te llamas?', 'Buenos días'],
    ),
    GoalTemplate(
      title: 'اللياقة البدنية',
      category: GoalCategory.fitness,
      description: '30 دقيقة تمرين يومياً',
      durationDays: 90,
      sampleLessons: ['10 دقائق إحماء', '20 دقيقة كارديو', '5 دقائق تهدئة'],
    ),
    GoalTemplate(
      title: 'تعلم التصميم',
      category: GoalCategory.design,
      description: 'من المبتدئ إلى المحترف',
      durationDays: 180,
      sampleLessons: ['مبادئ الألوان', 'الطباعة', 'تخطيط الصفحة'],
    ),
    GoalTemplate(
      title: 'عادة القراءة',
      category: GoalCategory.reading,
      description: 'كتاب شهرياً، 20 دقيقة يومياً',
      durationDays: 365,
      sampleLessons: ['اختر كتابك', 'اقرأ 10 صفحات', 'لخّص ما قرأت'],
    ),
    GoalTemplate(
      title: 'تعلم Python',
      category: GoalCategory.coding,
      description: 'من الصفر للبرمجة الاحترافية',
      durationDays: 180,
      sampleLessons: ['print("Hello")', 'المتغيرات', 'الحلقات'],
    ),
  ];
}
