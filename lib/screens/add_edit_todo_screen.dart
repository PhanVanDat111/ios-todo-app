import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/todo_item.dart';
import '../providers/todo_provider.dart';
import '../theme/ios_theme.dart';
import '../widgets/bouncy_tap.dart';

class AddEditTodoScreen extends StatefulWidget {
  final TodoItem? todoToEdit;
  final String? initialCategoryId;

  const AddEditTodoScreen({
    super.key,
    this.todoToEdit,
    this.initialCategoryId,
  });

  @override
  State<AddEditTodoScreen> createState() => _AddEditTodoScreenState();
}

class _AddEditTodoScreenState extends State<AddEditTodoScreen> {
  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _subtaskInputController;

  DateTime? _dueDate;
  DateTime? _reminderTime;
  PriorityLevel _priority = PriorityLevel.medium;
  late String _categoryId;
  List<SubTask> _subtasks = [];

  bool _hasDueDate = false;
  bool _hasReminder = false;

  @override
  void initState() {
    super.initState();
    final todo = widget.todoToEdit;
    _titleController = TextEditingController(text: todo?.title ?? '');
    _notesController = TextEditingController(text: todo?.notes ?? '');
    _subtaskInputController = TextEditingController();

    if (todo != null) {
      _dueDate = todo.dueDate;
      _reminderTime = todo.reminderTime;
      _priority = todo.priority;
      _categoryId = todo.categoryId;
      _subtasks = List.from(todo.subtasks);
      _hasDueDate = todo.dueDate != null;
      _hasReminder = todo.reminderTime != null;
    } else {
      _categoryId = widget.initialCategoryId ?? 'personal';
      _dueDate = DateTime.now();
      _hasDueDate = true;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _subtaskInputController.dispose();
    super.dispose();
  }

  void _addSubtask() {
    final text = _subtaskInputController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTask(
          id: const Uuid().v4(),
          title: text,
          isCompleted: false,
        ));
        _subtaskInputController.clear();
      });
    }
  }

  void _removeSubtask(int index) {
    setState(() {
      _subtasks.removeAt(index);
    });
  }

  void _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Thiếu tiêu đề'),
          content: const Text('Vui lòng nhập tiêu đề cho công việc cần làm.'),
          actions: [
            CupertinoDialogAction(
              child: const Text('OK'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      );
      return;
    }

    final provider = Provider.of<TodoProvider>(context, listen: false);

    final finalDueDate = _hasDueDate ? _dueDate : null;
    final finalReminderTime = _hasReminder ? _reminderTime : null;

    if (widget.todoToEdit != null) {
      final updated = widget.todoToEdit!.copyWith(
        title: title,
        notes: _notesController.text.trim(),
        dueDate: finalDueDate,
        reminderTime: finalReminderTime,
        priority: _priority,
        categoryId: _categoryId,
        subtasks: _subtasks,
      );
      await provider.updateTodo(updated);
    } else {
      await provider.addTodo(
        title: title,
        notes: _notesController.text.trim(),
        dueDate: finalDueDate,
        reminderTime: finalReminderTime,
        priority: _priority,
        categoryId: _categoryId,
        subtasks: _subtasks,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showDatePicker() {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Hủy'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                CupertinoButton(
                  child: const Text('Xong', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: _dueDate ?? DateTime.now(),
                minimumDate: DateTime(2020),
                maximumDate: DateTime(2035),
                onDateTimeChanged: (date) {
                  setState(() {
                    _dueDate = date;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePicker() {
    final now = DateTime.now();
    DateTime initial = _reminderTime ?? now.add(const Duration(minutes: 15));

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Container(
        height: 280,
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1C1C1E)
            : CupertinoColors.systemBackground.resolveFrom(context),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CupertinoButton(
                  child: const Text('Hủy'),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
                CupertinoButton(
                  child: const Text('Xong', style: TextStyle(fontWeight: FontWeight.bold)),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.time,
                use24hFormat: true,
                initialDateTime: initial,
                onDateTimeChanged: (time) {
                  setState(() {
                    final baseDate = _dueDate ?? DateTime.now();
                    _reminderTime = DateTime(
                      baseDate.year,
                      baseDate.month,
                      baseDate.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEditing = widget.todoToEdit != null;
    final categories = Provider.of<TodoProvider>(context).categories;

    return CupertinoPageScaffold(
      backgroundColor: isDark ? IOSTheme.darkBackground : IOSTheme.lightBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? const Color(0xCC161824) : const Color(0xCCFFFFFF),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Hủy'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        middle: Text(
          isEditing ? 'Sửa nhắc nhở' : 'Nhắc nhở mới',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _save,
          child: Text(
            isEditing ? 'Lưu' : 'Thêm',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: IOSTheme.primaryBlue,
            ),
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            children: [
              // Section 1: Title & Notes
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181A26) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                    width: 1,
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
                    CupertinoTextField(
                      controller: _titleController,
                      placeholder: 'Tiêu đề công việc...',
                      placeholderStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        fontSize: 17,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(),
                      autofocus: !isEditing,
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                      indent: 16,
                    ),
                    CupertinoTextField(
                      controller: _notesController,
                      placeholder: 'Thêm ghi chú chi tiết...',
                      placeholderStyle: TextStyle(
                        color: isDark ? Colors.grey[500] : Colors.grey[400],
                        fontSize: 15,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 15,
                      ),
                      padding: const EdgeInsets.all(16),
                      maxLines: 4,
                      minLines: 2,
                      decoration: const BoxDecoration(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 2: Date & Reminder Settings
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181A26) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                    width: 1,
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
                    // Due Date Switch
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF3B30), Color(0xFFFF5E3A)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(CupertinoIcons.calendar, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Text(
                              'Ngày hết hạn',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                          CupertinoSwitch(
                            value: _hasDueDate,
                            activeTrackColor: IOSTheme.systemGreen,
                            onChanged: (val) {
                              setState(() {
                                _hasDueDate = val;
                                if (val && _dueDate == null) {
                                  _dueDate = DateTime.now();
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_hasDueDate) ...[
                      Divider(
                        height: 1,
                        color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                        indent: 58,
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        onPressed: _showDatePicker,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Chọn ngày', style: TextStyle(color: Colors.grey, fontSize: 15)),
                            Text(
                              DateFormat('EEEE, dd/MM/yyyy').format(_dueDate ?? DateTime.now()),
                              style: const TextStyle(
                                color: IOSTheme.primaryBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                    ),

                    // Reminder Notification Switch
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF9500), Color(0xFFFF5E3A)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(CupertinoIcons.bell_fill, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hẹn giờ thông báo',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  'Nhắc nhở push notification khi đến giờ',
                                  style: TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          CupertinoSwitch(
                            value: _hasReminder,
                            activeTrackColor: IOSTheme.systemGreen,
                            onChanged: (val) {
                              setState(() {
                                _hasReminder = val;
                                if (val && _reminderTime == null) {
                                  final now = DateTime.now();
                                  _reminderTime = now.add(const Duration(minutes: 30));
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (_hasReminder) ...[
                      Divider(
                        height: 1,
                        color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                        indent: 58,
                      ),
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        onPressed: _showTimePicker,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Giờ nhắc nhở', style: TextStyle(color: Colors.grey, fontSize: 15)),
                            Text(
                              DateFormat('HH:mm').format(_reminderTime ?? DateTime.now()),
                              style: const TextStyle(
                                color: IOSTheme.systemOrange,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 3: Priority & Category
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181A26) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                    width: 1,
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
                    // Priority
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(CupertinoIcons.flag_fill, color: IOSTheme.systemRed, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Mức độ ưu tiên',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: CupertinoSlidingSegmentedControl<PriorityLevel>(
                              groupValue: _priority,
                              backgroundColor: isDark ? const Color(0xFF26293B) : const Color(0xFFF3F4F6),
                              thumbColor: isDark ? const Color(0xFF374151) : Colors.white,
                              children: {
                                PriorityLevel.low: _buildPrioritySegment('Thấp', PriorityLevel.low),
                                PriorityLevel.medium: _buildPrioritySegment('Trung bình', PriorityLevel.medium),
                                PriorityLevel.high: _buildPrioritySegment('Cao', PriorityLevel.high),
                                PriorityLevel.urgent: _buildPrioritySegment('Gấp!', PriorityLevel.urgent),
                              },
                              onValueChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _priority = val;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                    ),

                    // Category Selector
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(CupertinoIcons.folder_fill, color: IOSTheme.primaryBlue, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Danh mục',
                                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: categories.map((cat) {
                              final isSelected = _categoryId == cat.id;
                              return BouncyTap(
                                onTap: () {
                                  setState(() {
                                    _categoryId = cat.id;
                                  });
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? LinearGradient(
                                            colors: [cat.color, cat.color.withValues(alpha: 0.8)],
                                          )
                                        : null,
                                    color: isSelected
                                        ? null
                                        : (isDark ? const Color(0xFF26293B) : const Color(0xFFF3F4F6)),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: cat.color.withValues(alpha: 0.4),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        cat.icon,
                                        size: 14,
                                        color: isSelected
                                            ? Colors.white
                                            : (isDark ? Colors.grey[300] : cat.color),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        cat.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          color: isSelected
                                              ? Colors.white
                                              : (isDark ? Colors.grey[200] : const Color(0xFF374151)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Section 4: Subtasks (Checklist con)
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF181A26) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                    width: 1,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 16, top: 16, bottom: 10),
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.list_bullet, color: IOSTheme.systemPurple, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Công việc con (Subtasks)',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),

                    // Subtask input
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: CupertinoTextField(
                              controller: _subtaskInputController,
                              placeholder: 'Thêm bước thực hiện...',
                              placeholderStyle: TextStyle(
                                color: isDark ? Colors.grey[500] : Colors.grey[400],
                                fontSize: 14,
                              ),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 14,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF26293B) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              onSubmitted: (_) => _addSubtask(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          BouncyTap(
                            onTap: _addSubtask,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: IOSTheme.blueGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(CupertinoIcons.plus, size: 18, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subtasks list
                    if (_subtasks.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Divider(
                        height: 1,
                        color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                      ),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _subtasks.length,
                        separatorBuilder: (ctx, i) => Divider(
                          height: 1,
                          color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                          indent: 16,
                        ),
                        itemBuilder: (ctx, index) {
                          final st = _subtasks[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.circle_fill,
                                  size: 8,
                                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    st.title,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? Colors.white : Colors.black87,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeSubtask(index),
                                  child: const Icon(
                                    CupertinoIcons.minus_circle_fill,
                                    color: IOSTheme.systemRed,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrioritySegment(String title, PriorityLevel level) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: _priority == level ? level.color : null,
        ),
      ),
    );
  }
}
