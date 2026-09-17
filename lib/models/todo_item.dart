import 'package:flutter/material.dart';

enum PriorityLevel {
  low,
  medium,
  high,
  urgent,
}

extension PriorityExtension on PriorityLevel {
  String get displayName {
    switch (this) {
      case PriorityLevel.low:
        return 'Thấp';
      case PriorityLevel.medium:
        return 'Trung bình';
      case PriorityLevel.high:
        return 'Cao';
      case PriorityLevel.urgent:
        return 'Khẩn cấp!';
    }
  }

  Color get color {
    switch (this) {
      case PriorityLevel.low:
        return const Color(0xFF8E8E93);
      case PriorityLevel.medium:
        return const Color(0xFF007AFF);
      case PriorityLevel.high:
        return const Color(0xFFFF9500);
      case PriorityLevel.urgent:
        return const Color(0xFFFF3B30);
    }
  }

  int get level {
    switch (this) {
      case PriorityLevel.low:
        return 1;
      case PriorityLevel.medium:
        return 2;
      case PriorityLevel.high:
        return 3;
      case PriorityLevel.urgent:
        return 4;
    }
  }
}

class SubTask {
  final String id;
  String title;
  bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'isCompleted': isCompleted,
      };

  factory SubTask.fromJson(Map<String, dynamic> json) => SubTask(
        id: json['id'] as String,
        title: json['title'] as String,
        isCompleted: json['isCompleted'] as bool? ?? false,
      );
}

class TodoItem {
  final String id;
  String title;
  String? notes;
  DateTime? dueDate;
  DateTime? reminderTime;
  PriorityLevel priority;
  bool isCompleted;
  String categoryId;
  int? notificationId;
  List<SubTask> subtasks;
  DateTime createdAt;

  TodoItem({
    required this.id,
    required this.title,
    this.notes,
    this.dueDate,
    this.reminderTime,
    this.priority = PriorityLevel.medium,
    this.isCompleted = false,
    required this.categoryId,
    this.notificationId,
    List<SubTask>? subtasks,
    DateTime? createdAt,
  })  : subtasks = subtasks ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(dueDate!.year, dueDate!.month, dueDate!.day);
    return due.isBefore(today);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  TodoItem copyWith({
    String? id,
    String? title,
    String? notes,
    DateTime? dueDate,
    DateTime? reminderTime,
    PriorityLevel? priority,
    bool? isCompleted,
    String? categoryId,
    int? notificationId,
    List<SubTask>? subtasks,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      categoryId: categoryId ?? this.categoryId,
      notificationId: notificationId ?? this.notificationId,
      subtasks: subtasks ?? List.from(this.subtasks),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'notes': notes,
        'dueDate': dueDate?.toIso8601String(),
        'reminderTime': reminderTime?.toIso8601String(),
        'priority': priority.index,
        'isCompleted': isCompleted,
        'categoryId': categoryId,
        'notificationId': notificationId,
        'subtasks': subtasks.map((s) => s.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        id: json['id'] as String,
        title: json['title'] as String,
        notes: json['notes'] as String?,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'] as String) : null,
        reminderTime: json['reminderTime'] != null ? DateTime.parse(json['reminderTime'] as String) : null,
        priority: PriorityLevel.values[json['priority'] as int? ?? 1],
        isCompleted: json['isCompleted'] as bool? ?? false,
        categoryId: json['categoryId'] as String? ?? 'personal',
        notificationId: json['notificationId'] as int?,
        subtasks: (json['subtasks'] as List<dynamic>?)
                ?.map((s) => SubTask.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}
