import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../habits/presentation/providers/habit_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

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

  Future<void> _showAddHabitSheet(BuildContext context, WidgetRef ref) async {
    final notifier = ref.read(habitProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    await showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1B1E33) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Add Habit',
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              _HabitOptionTile(
                title: 'Workout',
                subtitle: 'Daily physical activity',
                icon: Icons.fitness_center,
                color: const Color(0xFFFF8A65),
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  await notifier.addWorkoutHabit();
                },
              ),
              const SizedBox(height: 12),
              _HabitOptionTile(
                title: 'Reading',
                subtitle: 'Read 10 pages daily',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFF5B8DEF),
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  await notifier.addReadingHabit();
                },
              ),
              const SizedBox(height: 12),
              _HabitOptionTile(
                title: 'Meditation',
                subtitle: '10 min mindfulness',
                icon: Icons.self_improvement,
                color: const Color(0xFF43A047),
                isDark: isDark,
                onTap: () async {
                  Navigator.pop(context);
                  await notifier.addMeditationHabit();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Color _habitColor(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('read')) return const Color(0xFF5B8DEF);
    if (lower.contains('meditation') || lower.contains('mindfulness')) {
      return const Color(0xFF43A047);
    }
    return const Color(0xFFFF8A65);
  }

  IconData _habitIcon(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('read')) return Icons.menu_book_rounded;
    if (lower.contains('meditation') || lower.contains('mindfulness')) {
      return Icons.self_improvement;
    }
    return Icons.fitness_center;
  }

  BoxDecoration _cardDecoration(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BoxDecoration(
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.05),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: isDark ? 0.22 : 0.08),
          blurRadius: 14,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Color _primaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white
        : const Color(0xFF171717);
  }

  Color _secondaryText(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? Colors.white70
        : const Color(0xFF5F6368);
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
            'Habit Mastery League',
            style: TextStyle(
              color: _primaryText(context),
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.settings, color: _primaryText(context)),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C5CFA).withValues(alpha: 0.40),
                blurRadius: 16,
              ),
            ],
          ),
          child: FloatingActionButton(
            onPressed: () => _showAddHabitSheet(context, ref),
            child: const Icon(Icons.add, color: Colors.white),
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
                height: 230,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/hero_bg.jpg'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.26),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withValues(alpha: 0.18),
                        Colors.black.withValues(alpha: 0.68),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.local_fire_department,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Level Up Daily',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.20),
                              ),
                              image: const DecorationImage(
                                image: AssetImage(
                                  'assets/images/ai_avatar.png',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Build Better Habits',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Stay consistent, track progress, and level up daily.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    _HeroMiniStat(label: 'XP', value: '$xp'),
                                    const SizedBox(width: 10),
                                    _HeroMiniStat(
                                      label: 'Level',
                                      value: '$level',
                                    ),
                                    const SizedBox(width: 10),
                                    _HeroMiniStat(label: 'Rank', value: rank),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      title: 'Habits',
                      value: '${habits.length}',
                      color: const Color(0xFF5B8DEF),
                      icon: Icons.track_changes,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      title: 'Focus',
                      value: focus,
                      color: const Color(0xFFFF8A65),
                      icon: Icons.bolt,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _InfoCard(
                      title: 'Rank',
                      value: rank,
                      color: const Color(0xFF43A047),
                      icon: Icons.workspace_premium,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Your Habits',
                style: TextStyle(
                  color: _primaryText(context),
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              if (habits.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: _cardDecoration(context),
                  child: Column(
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                              'assets/images/habit_illustration.png',
                            ),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No habits yet',
                        style: TextStyle(
                          color: _primaryText(context),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Start your first habit journey and build consistency one day at a time.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _secondaryText(context),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...habits.map((habit) {
                  final color = _habitColor(habit.title);
                  final icon = _habitIcon(habit.title);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: GestureDetector(
                      onTap: () => context.push('/habit/${habit.id}'),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.all(16),
                        decoration: _cardDecoration(context),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Icon(icon, color: color, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    habit.title,
                                    style: TextStyle(
                                      color: _primaryText(context),
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    habit.description,
                                    style: TextStyle(
                                      color: _secondaryText(context),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _MiniBadge(
                                        icon: Icons.color_lens_outlined,
                                        label: habit.title.contains('Read')
                                            ? 'Learning'
                                            : habit.title.contains('Meditation')
                                            ? 'Mindfulness'
                                            : 'Fitness',
                                        color: color,
                                      ),
                                      const SizedBox(width: 8),
                                      const _MiniBadge(
                                        icon: Icons.trending_up,
                                        label: 'Active',
                                        color: Color(0xFF7C5CFA),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(
                                        0xFF43A047,
                                      ).withValues(alpha: 0.18),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(5),
                                    child: const Icon(
                                      Icons.check,
                                      color: Color(0xFF43A047),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await notifier.completeHabit(habit.id);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${habit.title} completed!',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.fromLTRB(
                                          16,
                                          0,
                                          16,
                                          80,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () async {
                                    await notifier.deleteHabit(habit.id);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroMiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _HeroMiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  final bool isDark;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
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
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
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

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MiniBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitOptionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _HabitOptionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withValues(alpha: 0.18),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: isDark
                            ? Colors.white70
                            : const Color(0xFF5F6368),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? Colors.white70 : const Color(0xFF5F6368),
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
