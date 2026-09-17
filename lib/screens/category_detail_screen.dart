import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../providers/todo_provider.dart';
import '../theme/ios_theme.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/todo_tile.dart';
import 'add_edit_todo_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final TodoCategory category;

  const CategoryDetailScreen({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        final todos = provider.getTodosByCategory(category.id);
        final completedCount = todos.where((t) => t.isCompleted).length;
        final totalCount = todos.length;
        final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;
        final int percentInt = (progress * 100).toInt();

        return CupertinoPageScaffold(
          backgroundColor: isDark ? IOSTheme.darkBackground : IOSTheme.lightBackground,
          navigationBar: CupertinoNavigationBar(
            backgroundColor: isDark ? const Color(0xCC161824) : const Color(0xCCFFFFFF),
            previousPageTitle: 'Danh sách',
            middle: Text(
              category.name,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF111827),
              ),
            ),
            trailing: BouncyTap(
              onTap: () {
                Navigator.of(context).push(
                  CupertinoPageRoute(
                    fullscreenDialog: true,
                    builder: (ctx) => AddEditTodoScreen(
                      initialCategoryId: category.id,
                    ),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [category.color, category.color.withValues(alpha: 0.8)],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(CupertinoIcons.plus, size: 16, color: Colors.white),
              ),
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                children: [
                  // Header Summary Card with Gradient Glow
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [const Color(0xFF181A26), const Color(0xFF13141D)]
                            : [Colors.white, const Color(0xFFF9FAFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: category.color.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: category.color.withValues(alpha: isDark ? 0.25 : 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [category.color, category.color.withValues(alpha: 0.8)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: category.color.withValues(alpha: 0.45),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                category.icon,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.5,
                                      color: isDark ? Colors.white : const Color(0xFF111827),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$completedCount/$totalCount công việc hoàn thành ($percentInt%)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),

                        // Glowing iOS Progress Bar
                        Container(
                          height: 9,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: progress.clamp(0.0, 1.0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [category.color, category.color.withValues(alpha: 0.85)],
                                ),
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: [
                                  BoxShadow(
                                    color: category.color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tasks Header
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 10),
                    child: Text(
                      'CÔNG VIỆC (${todos.length})',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),

                  // Todo List
                  if (todos.isEmpty) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Icon(
                            CupertinoIcons.tray,
                            size: 48,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có công việc nào trong danh mục này',
                            style: TextStyle(
                              fontSize: 15,
                              color: isDark ? Colors.grey[500] : Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    ...todos.map((todo) => TodoTile(
                          todo: todo,
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                fullscreenDialog: true,
                                builder: (ctx) => AddEditTodoScreen(
                                  todoToEdit: todo,
                                ),
                              ),
                            );
                          },
                          onEdit: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                fullscreenDialog: true,
                                builder: (ctx) => AddEditTodoScreen(
                                  todoToEdit: todo,
                                ),
                              ),
                            );
                          },
                        )),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
