import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/export_service.dart';
import '../providers/habit_provider.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitProvider);
    final notifier = ref.read(habitProvider.notifier);

    final matches = habits.where((h) => h.id == habitId).toList();

    if (matches.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Habit Details')),
        body: const Center(child: Text('Habit not found')),
      );
    }

    final habit = matches.first;
    final color = _habitColor(habit.title);
    final icon = _habitIcon(habit.title);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1020), Color(0xFF17192E), Color(0xFF23264B)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Habit Details'),
          actions: [
            IconButton(
              onPressed: () async {
                final exportService = ExportService();
                final path = await exportService.exportHabitsToJson([
                  {
                    'id': habit.id,
                    'title': habit.title,
                    'description': habit.description,
                    'targetDays': habit.targetDays,
                    'createdAt': habit.createdAt.toIso8601String(),
                  },
                ]);

                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Exported to: $path')));
              },
              icon: const Icon(Icons.download_rounded),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(icon, color: color, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      habit.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      habit.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await notifier.completeHabit(habit.id);
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${habit.title} completed')),
                  );
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Mark Complete'),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => HabitEditScreen(habitId: habit.id),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Habit'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  await notifier.deleteHabit(habit.id);
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HabitEditScreen extends ConsumerStatefulWidget {
  final String habitId;

  const HabitEditScreen({super.key, required this.habitId});

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    final habits = ref.read(habitProvider);
    final habit = habits.firstWhere((h) => h.id == widget.habitId);
    _titleController = TextEditingController(text: habit.title);
    _descriptionController = TextEditingController(text: habit.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(habitProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F1020), Color(0xFF17192E), Color(0xFF23264B)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Edit Habit')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Habit title'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await notifier.updateHabit(
                  widget.habitId,
                  _titleController.text.trim(),
                  _descriptionController.text.trim(),
                );

                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Habit updated')));
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
