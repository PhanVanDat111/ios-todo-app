import 'package:flutter/cupertino.dart';

class TodoCategory {
  final String id;
  final String name;
  final int iconCode;
  final int colorValue;

  TodoCategory({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.colorValue,
  });

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(
        iconCode,
        fontFamily: CupertinoIcons.iconFont,
        fontPackage: CupertinoIcons.iconFontPackage,
      );
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'iconCode': iconCode,
        'colorValue': colorValue,
      };

  factory TodoCategory.fromJson(Map<String, dynamic> json) => TodoCategory(
        id: json['id'] as String,
        name: json['name'] as String,
        iconCode: json['iconCode'] as int,
        colorValue: json['colorValue'] as int,
      );

  static List<TodoCategory> get defaultCategories => [
        TodoCategory(
          id: 'personal',
          name: 'Cá nhân',
          iconCode: CupertinoIcons.person_fill.codePoint,
          colorValue: 0xFF007AFF, // iOS Blue
        ),
        TodoCategory(
          id: 'work',
          name: 'Công việc',
          iconCode: CupertinoIcons.briefcase_fill.codePoint,
          colorValue: 0xFFFF9500, // iOS Orange
        ),
        TodoCategory(
          id: 'study',
          name: 'Học tập',
          iconCode: CupertinoIcons.book_fill.codePoint,
          colorValue: 0xFF5856D6, // iOS Purple
        ),
        TodoCategory(
          id: 'shopping',
          name: 'Mua sắm',
          iconCode: CupertinoIcons.cart_fill.codePoint,
          colorValue: 0xFF34C759, // iOS Green
        ),
        TodoCategory(
          id: 'health',
          name: 'Sức khỏe',
          iconCode: CupertinoIcons.heart_fill.codePoint,
          colorValue: 0xFFFF2D55, // iOS Pink
        ),
      ];
}
