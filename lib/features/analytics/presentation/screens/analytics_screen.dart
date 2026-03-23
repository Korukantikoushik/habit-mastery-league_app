import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../habits/presentation/providers/habit_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  String _getLeagueRank(int level) {
    if (level >= 10) return 'S+';
    if (level >= 7) return 'S';
    if (level >= 5) return 'A';
    if (level >= 3) return 'B';
    return 'C';
  }

  String _getFocusLevel(int xp) {
    if (xp >= 200) return 'Elite';
    if (xp >= 120) return 'High';
    if (xp >= 50) return 'Medium';
    return 'Growing';
  }

  Color _habitColor(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('read')) return const Color(0xFF5B8DEF);
    if (lower.contains('meditation') || lower.contains('mindfulness')) {
      return const Color(0xFF43A047);
    }
    return const Color(0xFFFF8A65);
  }

  Map<String, int> _habitBreakdown(List habits) {
    int workout = 0;
    int reading = 0;
    int meditation = 0;

    for (final habit in habits) {
      final title = habit.title.toLowerCase();
      if (title.contains('read')) {
        reading++;
      } else if (title.contains('meditation') ||
          title.contains('mindfulness')) {
        meditation++;
      } else {
        workout++;
      }
    }

    return {'Workout': workout, 'Reading': reading, 'Meditation': meditation};
  }

  Color _primaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : Colors.black87;
  }

  Color _secondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : const Color(0xFF5F6368);
  }

  BoxDecoration _boxDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.05),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final notifier = ref.read(habitProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final xp = notifier.getXP();
    final level = notifier.getLevel();
    final rank = _getLeagueRank(level);
    final focus = _getFocusLevel(xp);
    final xpProgress = (xp % 100) / 100;
    final breakdown = _habitBreakdown(habits);

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
            'Analytics',
            style: TextStyle(
              color: _primaryText(context),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: RefreshIndicator(
          color: const Color(0xFF7C5CFA),
          onRefresh: () async {
            await ref.read(habitProvider.notifier).loadHabits();
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              Container(
                height: 220,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/hero_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.20),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Progress',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const Spacer(),
                      Text(
                        'Level $level  •  Rank $rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'XP: $xp   •   Focus: $focus',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          minHeight: 10,
                          value: xpProgress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(xpProgress * 100).toInt()}% to next level',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _AnalyticsStatCard(
                      title: 'Habits',
                      value: '${habits.length}',
                      icon: Icons.track_changes,
                      color: const Color(0xFF5B8DEF),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnalyticsStatCard(
                      title: 'Focus',
                      value: focus,
                      icon: Icons.bolt,
                      color: const Color(0xFFFF8A65),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _AnalyticsStatCard(
                      title: 'Rank',
                      value: rank,
                      icon: Icons.workspace_premium,
                      color: const Color(0xFF43A047),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Weekly Activity',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              FutureBuilder<List<int>>(
                future: notifier.getWeeklyData(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Container(
                      height: 200,
                      decoration: _boxDecoration(context),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF7C5CFA),
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data!;
                  final maxValue = data.isEmpty
                      ? 1
                      : data.reduce((a, b) => a > b ? a : b).clamp(1, 999);

                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: _boxDecoration(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completions this week',
                          style: TextStyle(
                            color: _secondaryText(context),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          height: 120,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(7, (index) {
                              final value = data[index].toDouble();
                              final height = maxValue == 0
                                  ? 8.0
                                  : ((value / maxValue) * 95).clamp(8.0, 95.0);

                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 22,
                                    height: height,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF7C5CFA),
                                          Color(0xFFA78BFA),
                                        ],
                                        begin: Alignment.bottomCenter,
                                        end: Alignment.topCenter,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    days[index],
                                    style: TextStyle(
                                      color: _secondaryText(context),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Habit Breakdown',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _boxDecoration(context),
                child: Column(
                  children: breakdown.entries.map((entry) {
                    final color = _habitColor(entry.key);
                    final total = habits.isEmpty ? 1 : habits.length;
                    final progress = entry.value / total;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(radius: 8, backgroundColor: color),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.key,
                                  style: TextStyle(
                                    color: _primaryText(context),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value}',
                                style: TextStyle(
                                  color: _secondaryText(context),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              minHeight: 8,
                              value: progress,
                              backgroundColor: isDark
                                  ? Colors.white12
                                  : Colors.black12,
                              valueColor: AlwaysStoppedAnimation<Color>(color),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Quick Summary',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: _boxDecoration(context),
                child: Column(
                  children: [
                    _SummaryTile(
                      label: 'Total habits',
                      value: '${habits.length}',
                      isDark: isDark,
                    ),
                    _SummaryTile(
                      label: 'Current XP',
                      value: '$xp',
                      isDark: isDark,
                    ),
                    _SummaryTile(
                      label: 'Current level',
                      value: '$level',
                      isDark: isDark,
                    ),
                    _SummaryTile(
                      label: 'League rank',
                      value: rank,
                      isDark: isDark,
                    ),
                    _SummaryTile(
                      label: 'Focus level',
                      value: focus,
                      isDark: isDark,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _AnalyticsStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 118,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white70 : const Color(0xFF5F6368),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isLast;

  const _SummaryTile({
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
                color: isDark ? Colors.white70 : const Color(0xFF5F6368),
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
