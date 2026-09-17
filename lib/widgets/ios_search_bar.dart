import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IOSSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final String placeholder;

  const IOSSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
    this.placeholder = 'Tìm kiếm công việc...',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CupertinoSearchTextField(
      controller: controller,
      onChanged: onChanged,
      onSuffixTap: onClear,
      placeholder: placeholder,
      placeholderStyle: TextStyle(
        color: isDark ? const Color(0xFF8E8E93) : const Color(0xFF8E8E93),
        fontSize: 15,
      ),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
        fontSize: 15,
      ),
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFE3E3E8),
      borderRadius: BorderRadius.circular(10),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
    );
  }
}
