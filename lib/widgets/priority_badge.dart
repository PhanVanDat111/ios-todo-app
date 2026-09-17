import 'package:flutter/cupertino.dart';
import '../models/todo_item.dart';

class PriorityBadge extends StatelessWidget {
  final PriorityLevel priority;
  final bool isCompact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (priority == PriorityLevel.low && isCompact) {
      return const SizedBox.shrink();
    }

    final color = priority.color;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.35),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (priority == PriorityLevel.urgent)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Icon(
                CupertinoIcons.flame_fill,
                size: isCompact ? 11 : 13,
                color: color,
              ),
            )
          else
            Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.6),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
          Text(
            priority.displayName,
            style: TextStyle(
              color: color,
              fontSize: isCompact ? 10 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
