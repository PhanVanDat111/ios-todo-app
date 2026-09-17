import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/todo_item.dart';

class StorageService {
  static const String _todosKey = 'ios_todo_app_items';
  static const String _categoriesKey = 'ios_todo_app_categories';

  static Future<List<TodoItem>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_todosKey);
    if (jsonString == null || jsonString.isEmpty) {
      return _initialSeedTodos();
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => TodoItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return _initialSeedTodos();
    }
  }

  static Future<void> saveTodos(List<TodoItem> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(todos.map((t) => t.toJson()).toList());
    await prefs.setString(_todosKey, jsonString);
  }

  static Future<List<TodoCategory>> loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_categoriesKey);
    if (jsonString == null || jsonString.isEmpty) {
      return TodoCategory.defaultCategories;
    }
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((item) => TodoCategory.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return TodoCategory.defaultCategories;
    }
  }

  static Future<void> saveCategories(List<TodoCategory> categories) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(categories.map((c) => c.toJson()).toList());
    await prefs.setString(_categoriesKey, jsonString);
  }

  static List<TodoItem> _initialSeedTodos() {
    final now = DateTime.now();
    return [
      TodoItem(
        id: '1',
        title: 'Hoàn thiện giao diện ứng dụng Todo iOS',
        notes: 'Sử dụng Cupertino style, hỗ trợ Dark/Light mode và swipe gestures.',
        dueDate: now,
        reminderTime: now.add(const Duration(hours: 2)),
        priority: PriorityLevel.urgent,
        isCompleted: false,
        categoryId: 'work',
        subtasks: [
          SubTask(id: 's1', title: 'Thiết kế card widget', isCompleted: true),
          SubTask(id: 's2', title: 'Tích hợp bộ hẹn giờ thông báo', isCompleted: false),
          SubTask(id: 's3', title: 'Thêm bộ lọc theo danh mục', isCompleted: false),
        ],
      ),
      TodoItem(
        id: '2',
        title: 'Mua quà sinh nhật cho bạn thân',
        notes: 'Chọn tai nghe hoặc sách công nghệ',
        dueDate: now.add(const Duration(days: 2)),
        reminderTime: now.add(const Duration(days: 1, hours: 10)),
        priority: PriorityLevel.high,
        isCompleted: false,
        categoryId: 'shopping',
      ),
      TodoItem(
        id: '3',
        title: 'Chạy bộ 5km buổi sáng',
        notes: 'Mang theo tai nghe và bình nước',
        dueDate: now,
        priority: PriorityLevel.medium,
        isCompleted: true,
        categoryId: 'health',
      ),
      TodoItem(
        id: '4',
        title: 'Đọc 20 trang sách Thiết kế ứng dụng di động',
        notes: 'Chương 4: Tâm lý học màu sắc và trải nghiệm người dùng iOS',
        dueDate: now.add(const Duration(days: 1)),
        priority: PriorityLevel.low,
        isCompleted: false,
        categoryId: 'study',
      ),
    ];
  }
}
