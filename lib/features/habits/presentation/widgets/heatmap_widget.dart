import 'package:flutter/material.dart';

class HeatmapWidget extends StatelessWidget {
  final List<DateTime> logs;

  const HeatmapWidget({super.key, required this.logs});

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  int _completionCountForDay(DateTime day) {
    return logs.where((log) => _isSameDay(log, day)).length;
  }

  Color _cellColor(int count) {
    if (count >= 3) return const Color(0xFF7C5CFA);
    if (count == 2) return const Color(0xFF9B8CFF);
    if (count == 1) return const Color(0xFF43A047);
    return Colors.white.withValues(alpha: 0.08);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(
      28,
      (index) => DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 27 - index)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Last 28 Days',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: days.map((day) {
            final count = _completionCountForDay(day);
            final isToday = _isSameDay(day, now);

            return Tooltip(
              message:
                  '${day.day}/${day.month}/${day.year} • $count completion${count == 1 ? '' : 's'}',
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: _cellColor(count),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.05),
                    width: isToday ? 1.1 : 0.8,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
