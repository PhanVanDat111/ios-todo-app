import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../theme/ios_theme.dart';

class DailyProgressBanner extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final int todayTasks;

  const DailyProgressBanner({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.todayTasks,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Chào buổi sáng! ☀️';
    } else if (hour < 18) {
      return 'Chào buổi chiều! 🌤️';
    } else {
      return 'Chào buổi tối! 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double percent = totalTasks == 0 ? 0.0 : (completedTasks / totalTasks).clamp(0.0, 1.0);
    final int percentInt = (percent * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1B4B), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), const Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF3730A3).withValues(alpha: 0.5) : const Color(0xFFC7D2FE),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? const Color(0xFF3730A3) : const Color(0xFF6366F1)).withValues(alpha: isDark ? 0.25 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Circular Progress Indicator with Glow
          SizedBox(
            width: 64,
            height: 64,
            child: Stack(
              alignment: Alignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: percent),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6.5,
                      backgroundColor: isDark
                          ? const Color(0xFF312E81)
                          : const Color(0xFFC7D2FE),
                      valueColor: const AlwaysStoppedAnimation<Color>(IOSTheme.primaryBlue),
                      strokeCap: StrokeCap.round,
                    );
                  },
                ),
                Text(
                  '$percentInt%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Greeting & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : const Color(0xFF1E1B4B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  todayTasks > 0
                      ? 'Bạn có $todayTasks công việc cần hoàn thành hôm nay'
                      : 'Tuyệt vời! Bạn đã hoàn thành các mục tiêu',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),

          // Sparkle icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: IOSTheme.primaryBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.sparkles,
              color: IOSTheme.primaryBlue,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
