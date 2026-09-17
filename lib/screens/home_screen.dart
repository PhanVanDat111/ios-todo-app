import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../theme/ios_theme.dart';
import '../widgets/bouncy_tap.dart';
import '../widgets/category_card.dart';
import '../widgets/daily_progress_banner.dart';
import '../widgets/ios_search_bar.dart';
import '../widgets/todo_tile.dart';
import 'add_edit_todo_screen.dart';
import 'category_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    int selectedColor = 0xFF007AFF;
    int selectedIcon = CupertinoIcons.tag_fill.codePoint;

    final colors = [
      0xFF007AFF, // Blue
      0xFFFF9500, // Orange
      0xFFFF3B30, // Red
      0xFF34C759, // Green
      0xFF5856D6, // Purple
      0xFFFF2D55, // Pink
      0xFF5AC8FA, // Teal
    ];

    final icons = [
      CupertinoIcons.tag_fill,
      CupertinoIcons.heart_fill,
      CupertinoIcons.star_fill,
      CupertinoIcons.bookmark_fill,
      CupertinoIcons.cart_fill,
      CupertinoIcons.car_detailed,
      CupertinoIcons.gift_fill,
      CupertinoIcons.house_fill,
    ];

    showCupertinoDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => CupertinoAlertDialog(
          title: const Text('Danh sách mới'),
          content: Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Column(
              children: [
                CupertinoTextField(
                  controller: nameController,
                  placeholder: 'Tên danh mục...',
                  autofocus: true,
                ),
                const SizedBox(height: 14),
                // Color pickers
                Wrap(
                  spacing: 6,
                  children: colors.map((c) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedColor = c),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == c ? Colors.black : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                // Icon pickers
                Wrap(
                  spacing: 8,
                  children: icons.map((ic) {
                    return GestureDetector(
                      onTap: () => setDialogState(() => selectedIcon = ic.codePoint),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: selectedIcon == ic.codePoint ? Colors.grey[300] : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(ic, size: 20, color: Color(selectedColor)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('Tạo'),
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isNotEmpty) {
                  Provider.of<TodoProvider>(context, listen: false).addCategory(
                    name: name,
                    iconCode: selectedIcon,
                    colorValue: selectedColor,
                  );
                }
                Navigator.of(ctx).pop();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<TodoProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const CupertinoPageScaffold(
            child: Center(child: CupertinoActivityIndicator(radius: 14)),
          );
        }

        final filteredTodos = provider.filteredTodos;
        final completedCount = provider.completedCount;
        final totalCount = provider.todos.length;

        return CupertinoPageScaffold(
          backgroundColor: isDark ? IOSTheme.darkBackground : IOSTheme.lightBackground,
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Top Navigation Header with Glass Look
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Nhắc nhở',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.8,
                                    color: isDark ? Colors.white : const Color(0xFF111827),
                                  ),
                                ),
                                Text(
                                  '${provider.allCount} việc cần làm',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                  ),
                                ),
                              ],
                            ),
                            BouncyTap(
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (ctx) => const SettingsScreen(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? const Color(0xFF181A26) : Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isDark ? const Color(0xFF2B2E42) : const Color(0xFFE5E7EB),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  CupertinoIcons.gear_alt_fill,
                                  size: 20,
                                  color: isDark ? Colors.white : const Color(0xFF374151),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        child: IOSSearchBar(
                          controller: _searchController,
                          onChanged: (val) => provider.setSearchQuery(val),
                          onClear: () => provider.setSearchQuery(''),
                        ),
                      ),

                      // Main Content Body
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          children: [
                            // Daily Progress Hero Banner
                            DailyProgressBanner(
                              completedTasks: completedCount,
                              totalTasks: totalCount,
                              todayTasks: provider.todayCount,
                            ),

                            // 2x2 Grid for Smart Filters
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.45,
                              children: [
                                CategoryCard(
                                  title: 'Hôm nay',
                                  count: provider.todayCount,
                                  icon: CupertinoIcons.calendar_today,
                                  iconColor: IOSTheme.primaryBlue,
                                  isSelected: provider.activeFilter == TaskFilter.today,
                                  onTap: () {
                                    provider.setActiveFilter(
                                      provider.activeFilter == TaskFilter.today
                                          ? TaskFilter.all
                                          : TaskFilter.today,
                                    );
                                  },
                                ),
                                CategoryCard(
                                  title: 'Đã lên lịch',
                                  count: provider.scheduledCount,
                                  icon: CupertinoIcons.calendar,
                                  iconColor: IOSTheme.systemRed,
                                  isSelected: provider.activeFilter == TaskFilter.scheduled,
                                  onTap: () {
                                    provider.setActiveFilter(
                                      provider.activeFilter == TaskFilter.scheduled
                                          ? TaskFilter.all
                                          : TaskFilter.scheduled,
                                    );
                                  },
                                ),
                                CategoryCard(
                                  title: 'Tất cả',
                                  count: provider.allCount,
                                  icon: CupertinoIcons.tray_fill,
                                  iconColor: IOSTheme.primaryIndigo,
                                  isSelected: provider.activeFilter == TaskFilter.all,
                                  onTap: () {
                                    provider.setActiveFilter(TaskFilter.all);
                                  },
                                ),
                                CategoryCard(
                                  title: 'Khẩn cấp',
                                  count: provider.urgentCount,
                                  icon: CupertinoIcons.flame_fill,
                                  iconColor: IOSTheme.systemOrange,
                                  isSelected: provider.activeFilter == TaskFilter.urgent,
                                  onTap: () {
                                    provider.setActiveFilter(
                                      provider.activeFilter == TaskFilter.urgent
                                          ? TaskFilter.all
                                          : TaskFilter.urgent,
                                    );
                                  },
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Section: My Lists (Categories)
                            _buildSectionHeader('DANH SÁCH CỦA TÔI', isDark),
                            Container(
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF181A26) : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
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
                              child: ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: provider.categories.length,
                                separatorBuilder: (ctx, i) => Divider(
                                  height: 1,
                                  color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                                  indent: 52,
                                ),
                                itemBuilder: (ctx, index) {
                                  final cat = provider.categories[index];
                                  final count = provider.getCategoryTodoCount(cat.id);

                                  return BouncyTap(
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (c) => CategoryDetailScreen(category: cat),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [cat.color, cat.color.withValues(alpha: 0.8)],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: cat.color.withValues(alpha: 0.4),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Icon(cat.icon, color: Colors.white, size: 16),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Text(
                                              cat.name,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: isDark ? Colors.white : const Color(0xFF111827),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: (isDark ? const Color(0xFF26293B) : const Color(0xFFF3F4F6)),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '$count',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Icon(
                                            CupertinoIcons.chevron_forward,
                                            size: 15,
                                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Section: Active Tasks List
                            _buildSectionHeader(
                              _getFilterSectionTitle(provider.activeFilter, filteredTodos.length),
                              isDark,
                            ),

                            if (filteredTodos.isEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 40),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: IOSTheme.primaryBlue.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        CupertinoIcons.checkmark_seal_fill,
                                        size: 40,
                                        color: IOSTheme.primaryBlue.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Không có công việc nào cần làm',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Bấm vào "+ Nhắc nhở mới" để tạo việc cần làm',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? const Color(0xFF6B7280) : const Color(0xFF9CA3AF),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ] else ...[
                              ...filteredTodos.map((todo) => TodoTile(
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

                            const SizedBox(height: 90), // Spacing for floating bar
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Floating Bottom iOS Action Bar with Glow
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xEE161824) : const Color(0xF5FFFFFF),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: isDark ? const Color(0x40FFFFFF) : const Color(0xFFE5E7EB),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Glowing Add Reminder Button
                          BouncyTap(
                            onTap: () {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  fullscreenDialog: true,
                                  builder: (ctx) => const AddEditTodoScreen(),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: IOSTheme.blueGradient,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: IOSTheme.primaryBlue.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                children: [
                                  Icon(CupertinoIcons.plus, size: 18, color: Colors.white),
                                  SizedBox(width: 6),
                                  Text(
                                    'Nhắc nhở mới',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Add List Button
                          BouncyTap(
                            onTap: () => _showAddCategoryDialog(context),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.folder_badge_plus,
                                    size: 18,
                                    color: isDark ? Colors.white : const Color(0xFF374151),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Thêm danh sách',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white : const Color(0xFF374151),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  String _getFilterSectionTitle(TaskFilter filter, int count) {
    switch (filter) {
      case TaskFilter.today:
        return 'HÔM NAY ($count)';
      case TaskFilter.scheduled:
        return 'ĐÃ LÊN LỊCH ($count)';
      case TaskFilter.all:
        return 'TẤT CẢ CÔNG VIỆC ($count)';
      case TaskFilter.urgent:
        return 'KHẨN CẤP ($count)';
      case TaskFilter.completed:
        return 'ĐÃ HOÀN THÀNH ($count)';
    }
  }
}
