import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../theme/ios_theme.dart';
import 'bouncy_tap.dart';
import 'priority_badge.dart';

class TodoTile extends StatefulWidget {
  final TodoItem todo;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  const TodoTile({
    super.key,
    required this.todo,
    required this.onTap,
    required this.onEdit,
  });

  @override
  State<TodoTile> createState() => _TodoTileState();
}

class _TodoTileState extends State<TodoTile> with SingleTickerProviderStateMixin {
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 0.8), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.15), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.15, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _checkController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final todoProvider = Provider.of<TodoProvider>(context, listen: false);
    final category = todoProvider.getCategoryById(widget.todo.categoryId);

    final completedSubtasks = widget.todo.subtasks.where((s) => s.isCompleted).length;
    final totalSubtasks = widget.todo.subtasks.length;
    final accentColor = category?.color ?? IOSTheme.primaryBlue;

    return Dismissible(
      key: Key(widget.todo.id),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: IOSTheme.blueGradient,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          children: [
            Icon(CupertinoIcons.pencil, color: Colors.white, size: 22),
            SizedBox(width: 8),
            Text(
              'Chỉnh sửa',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFF3B30), Color(0xFFFF5252)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Xóa',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
            ),
            SizedBox(width: 8),
            Icon(CupertinoIcons.delete_solid, color: Colors.white, size: 22),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          widget.onEdit();
          return false;
        } else {
          return await showCupertinoDialog<bool>(
                context: context,
                builder: (ctx) => CupertinoAlertDialog(
                  title: const Text('Xác nhận xóa'),
                  content: Text('Bạn có chắc chắn muốn xóa "${widget.todo.title}"?'),
                  actions: [
                    CupertinoDialogAction(
                      isDefaultAction: true,
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Hủy'),
                    ),
                    CupertinoDialogAction(
                      isDestructiveAction: true,
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              ) ??
              false;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          todoProvider.deleteTodo(widget.todo.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: widget.todo.isCompleted
              ? (isDark ? const Color(0xFF13141D) : const Color(0xFFF9FAFC))
              : (isDark ? const Color(0xFF181A26) : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.todo.isCompleted
                ? Colors.transparent
                : (isDark ? const Color(0xFF26293B) : const Color(0xFFEAEDF3)),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Checkbox with Spring Animation
                    BouncyTap(
                      onTap: () {
                        _checkController.forward(from: 0.0);
                        todoProvider.toggleTodoStatus(widget.todo.id);
                      },
                      child: AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _scaleAnimation.value,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            curve: Curves.easeOutCubic,
                            width: 26,
                            height: 26,
                            margin: const EdgeInsets.only(top: 2, right: 14),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: widget.todo.isCompleted
                                  ? LinearGradient(
                                      colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : null,
                              color: widget.todo.isCompleted ? null : Colors.transparent,
                              border: Border.all(
                                color: widget.todo.isCompleted
                                    ? accentColor
                                    : (isDark ? const Color(0xFF4B5563) : const Color(0xFFCBD5E1)),
                                width: 2,
                              ),
                              boxShadow: widget.todo.isCompleted
                                  ? [
                                      BoxShadow(
                                        color: accentColor.withValues(alpha: 0.45),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: widget.todo.isCompleted
                                ? const Icon(
                                    CupertinoIcons.checkmark_alt,
                                    size: 16,
                                    color: Colors.white,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    ),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title & Priority
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.todo.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: widget.todo.isCompleted
                                        ? (isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF))
                                        : (isDark ? Colors.white : const Color(0xFF111827)),
                                    decoration: widget.todo.isCompleted
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                    decorationColor: isDark ? Colors.grey[600] : Colors.grey[400],
                                    decorationThickness: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PriorityBadge(
                                priority: widget.todo.priority,
                                isCompact: true,
                              ),
                            ],
                          ),

                          // Notes preview
                          if (widget.todo.notes != null && widget.todo.notes!.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              widget.todo.notes!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.3,
                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                              ),
                            ),
                          ],

                          const SizedBox(height: 10),

                          // Metadata row: Date, Reminder, Category, Subtasks
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              // Due date
                              if (widget.todo.dueDate != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: _getDateColor(widget.todo).withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        CupertinoIcons.calendar,
                                        size: 13,
                                        color: _getDateColor(widget.todo),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(widget.todo.dueDate!),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: _getDateColor(widget.todo),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Reminder time
                              if (widget.todo.reminderTime != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: IOSTheme.systemOrange.withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        CupertinoIcons.bell_fill,
                                        size: 12,
                                        color: IOSTheme.systemOrange,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        DateFormat('HH:mm').format(widget.todo.reminderTime!),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: IOSTheme.systemOrange,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Category chip
                              if (category != null) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: category.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        category.icon,
                                        size: 12,
                                        color: category.color,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        category.name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: category.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              // Subtasks count badge
                              if (totalSubtasks > 0) ...[
                                BouncyTap(
                                  onTap: () {
                                    setState(() {
                                      _isExpanded = !_isExpanded;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          CupertinoIcons.list_bullet,
                                          size: 12,
                                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$completedSubtasks/$totalSubtasks',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? Colors.grey[300] : Colors.grey[700],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          _isExpanded
                                              ? CupertinoIcons.chevron_up
                                              : CupertinoIcons.chevron_down,
                                          size: 10,
                                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expanded Subtasks list
            if (_isExpanded && widget.todo.subtasks.isNotEmpty) ...[
              Divider(
                height: 1,
                indent: 52,
                color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 52, right: 16, top: 10, bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.todo.subtasks.map((subtask) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          todoProvider.toggleSubTask(widget.todo.id, subtask.id);
                        },
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: subtask.isCompleted ? IOSTheme.systemGreen : Colors.transparent,
                                border: Border.all(
                                  color: subtask.isCompleted
                                      ? IOSTheme.systemGreen
                                      : (isDark ? Colors.grey[600]! : Colors.grey[400]!),
                                  width: 1.5,
                                ),
                              ),
                              child: subtask.isCompleted
                                  ? const Icon(
                                      CupertinoIcons.checkmark,
                                      size: 11,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                subtask.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtask.isCompleted
                                      ? (isDark ? Colors.grey[500] : Colors.grey[400])
                                      : (isDark ? Colors.grey[200] : Colors.grey[800]),
                                  decoration: subtask.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDateColor(TodoItem todo) {
    if (todo.isCompleted) {
      return Colors.grey;
    }
    if (todo.isOverdue) {
      return IOSTheme.systemRed;
    }
    if (todo.isDueToday) {
      return IOSTheme.systemOrange;
    }
    return IOSTheme.primaryBlue;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Hôm nay';
    } else if (itemDate == tomorrow) {
      return 'Ngày mai';
    } else if (itemDate.year == now.year) {
      return DateFormat('dd/MM').format(date);
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
