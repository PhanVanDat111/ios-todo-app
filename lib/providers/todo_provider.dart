import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/category.dart';
import '../models/todo_item.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';

enum TaskFilter {
  today,
  scheduled,
  all,
  urgent,
  completed,
}

class TodoProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  final Uuid _uuid = const Uuid();

  List<TodoItem> _todos = [];
  List<TodoCategory> _categories = [];
  bool _isLoading = true;
  String _searchQuery = '';
  TaskFilter _activeFilter = TaskFilter.all;
  bool _isDarkMode = false;

  List<TodoItem> get todos => _todos;
  List<TodoCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  TaskFilter get activeFilter => _activeFilter;
  bool get isDarkMode => _isDarkMode;

  TodoProvider() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    _categories = await StorageService.loadCategories();
    _todos = await StorageService.loadTodos();

    _isLoading = false;
    notifyListeners();
  }

  void toggleTheme(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setActiveFilter(TaskFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  // Count Getters for Dashboard Badges
  int get todayCount {
    final now = DateTime.now();
    return _todos.where((t) {
      if (t.isCompleted) return false;
      if (t.dueDate == null) return false;
      return t.dueDate!.year == now.year &&
          t.dueDate!.month == now.month &&
          t.dueDate!.day == now.day;
    }).length;
  }

  int get scheduledCount {
    return _todos.where((t) => !t.isCompleted && t.dueDate != null).length;
  }

  int get allCount {
    return _todos.where((t) => !t.isCompleted).length;
  }

  int get urgentCount {
    return _todos.where((t) => !t.isCompleted && t.priority == PriorityLevel.urgent).length;
  }

  int get completedCount {
    return _todos.where((t) => t.isCompleted).length;
  }

  int getCategoryTodoCount(String categoryId) {
    return _todos.where((t) => !t.isCompleted && t.categoryId == categoryId).length;
  }

  TodoCategory? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Filtered List for UI
  List<TodoItem> get filteredTodos {
    List<TodoItem> list = List.from(_todos);

    // Apply Filter
    final now = DateTime.now();
    switch (_activeFilter) {
      case TaskFilter.today:
        list = list.where((t) {
          if (t.dueDate == null) return false;
          return t.dueDate!.year == now.year &&
              t.dueDate!.month == now.month &&
              t.dueDate!.day == now.day;
        }).toList();
        break;
      case TaskFilter.scheduled:
        list = list.where((t) => t.dueDate != null).toList();
        break;
      case TaskFilter.all:
        // Shows all incomplete tasks
        list = list.where((t) => !t.isCompleted).toList();
        break;
      case TaskFilter.urgent:
        list = list.where((t) => t.priority == PriorityLevel.urgent).toList();
        break;
      case TaskFilter.completed:
        list = list.where((t) => t.isCompleted).toList();
        break;
    }

    // Apply Search
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((t) {
        final titleMatch = t.title.toLowerCase().contains(q);
        final notesMatch = t.notes?.toLowerCase().contains(q) ?? false;
        return titleMatch || notesMatch;
      }).toList();
    }

    // Sort by: Incomplete first, then Priority (Urgent first), then Due Date
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      if (a.priority.level != b.priority.level) {
        return b.priority.level.compareTo(a.priority.level);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      return 0;
    });

    return list;
  }

  List<TodoItem> getTodosByCategory(String categoryId) {
    return _todos.where((t) => t.categoryId == categoryId).toList();
  }

  // Actions
  Future<void> addTodo({
    required String title,
    String? notes,
    DateTime? dueDate,
    DateTime? reminderTime,
    PriorityLevel priority = PriorityLevel.medium,
    required String categoryId,
    List<SubTask>? subtasks,
  }) async {
    final newTodo = TodoItem(
      id: _uuid.v4(),
      title: title.trim(),
      notes: notes?.trim(),
      dueDate: dueDate,
      reminderTime: reminderTime,
      priority: priority,
      categoryId: categoryId,
      subtasks: subtasks ?? [],
    );

    if (reminderTime != null) {
      final notifId = await _notificationService.scheduleTodoReminder(newTodo);
      if (notifId != -1) {
        newTodo.notificationId = notifId;
      }
    }

    _todos.add(newTodo);
    notifyListeners();
    await StorageService.saveTodos(_todos);
  }

  Future<void> updateTodo(TodoItem updatedTodo) async {
    final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
    if (index != -1) {
      // Cancel previous notification if exists
      if (_todos[index].notificationId != null) {
        await _notificationService.cancelReminder(_todos[index].notificationId!);
      }

      // Schedule new notification if reminder is set and not completed
      if (updatedTodo.reminderTime != null && !updatedTodo.isCompleted) {
        final notifId = await _notificationService.scheduleTodoReminder(updatedTodo);
        if (notifId != -1) {
          updatedTodo.notificationId = notifId;
        }
      }

      _todos[index] = updatedTodo;
      notifyListeners();
      await StorageService.saveTodos(_todos);
    }
  }

  Future<void> toggleTodoStatus(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final item = _todos[index];
      final newStatus = !item.isCompleted;
      item.isCompleted = newStatus;

      if (newStatus && item.notificationId != null) {
        await _notificationService.cancelReminder(item.notificationId!);
      } else if (!newStatus && item.reminderTime != null) {
        final notifId = await _notificationService.scheduleTodoReminder(item);
        if (notifId != -1) {
          item.notificationId = notifId;
        }
      }

      notifyListeners();
      await StorageService.saveTodos(_todos);
    }
  }

  Future<void> deleteTodo(String id) async {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      final item = _todos[index];
      if (item.notificationId != null) {
        await _notificationService.cancelReminder(item.notificationId!);
      }
      _todos.removeAt(index);
      notifyListeners();
      await StorageService.saveTodos(_todos);
    }
  }

  Future<void> toggleSubTask(String todoId, String subTaskId) async {
    final todoIndex = _todos.indexWhere((t) => t.id == todoId);
    if (todoIndex != -1) {
      final subIndex = _todos[todoIndex].subtasks.indexWhere((s) => s.id == subTaskId);
      if (subIndex != -1) {
        _todos[todoIndex].subtasks[subIndex].isCompleted =
            !_todos[todoIndex].subtasks[subIndex].isCompleted;
        notifyListeners();
        await StorageService.saveTodos(_todos);
      }
    }
  }

  Future<void> addCategory({
    required String name,
    required int iconCode,
    required int colorValue,
  }) async {
    final newCat = TodoCategory(
      id: _uuid.v4(),
      name: name.trim(),
      iconCode: iconCode,
      colorValue: colorValue,
    );
    _categories.add(newCat);
    notifyListeners();
    await StorageService.saveCategories(_categories);
  }

  Future<void> deleteCategory(String categoryId) async {
    _categories.removeWhere((c) => c.id == categoryId);
    // Re-assign orphaned tasks to 'personal'
    for (var t in _todos.where((t) => t.categoryId == categoryId)) {
      t.categoryId = 'personal';
    }
    notifyListeners();
    await StorageService.saveCategories(_categories);
    await StorageService.saveTodos(_todos);
  }
}
