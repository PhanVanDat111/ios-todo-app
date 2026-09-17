import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../services/notification_service.dart';
import '../theme/ios_theme.dart';
import '../widgets/bouncy_tap.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TodoProvider>(context);

    return CupertinoPageScaffold(
      backgroundColor: isDark ? IOSTheme.darkBackground : IOSTheme.lightBackground,
      navigationBar: CupertinoNavigationBar(
        backgroundColor: isDark ? const Color(0xCC161824) : const Color(0xCCFFFFFF),
        previousPageTitle: 'Quay lại',
        middle: Text(
          'Cài đặt',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF111827),
          ),
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            children: [
              // Section 1: Appearance
              _buildSectionHeader('GIAO DIỆN', isDark),
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF5856D6), Color(0xFFBF5AF2)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(CupertinoIcons.moon_fill, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Chế độ nền tối (Dark Mode)',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                      CupertinoSwitch(
                        value: provider.isDarkMode,
                        activeTrackColor: IOSTheme.systemGreen,
                        onChanged: (val) {
                          provider.toggleTheme(val);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Section 2: Notifications & Reminders
              _buildSectionHeader('THÔNG BÁO & NHẮC NHỞ', isDark),
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
                    // Test Notification Button
                    BouncyTap(
                      onTap: () async {
                        await NotificationService().showInstantTestNotification(
                          title: '🔔 Thông báo thử nghiệm!',
                          body: 'Hệ thống thông báo đẩy iOS trên ứng dụng Todo đã hoạt động hoàn hảo.',
                        );
                        if (context.mounted) {
                          showCupertinoDialog(
                            context: context,
                            builder: (ctx) => CupertinoAlertDialog(
                              title: const Text('Đã gửi thông báo'),
                              content: const Text('Vui lòng kiểm tra thanh thông báo (Notification Center) trên thiết bị của bạn.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                              child: Text(
                                'Gửi thông báo thử nghiệm ngay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: IOSTheme.primaryBlue,
                                ),
                              ),
                            ),
                            const Icon(CupertinoIcons.chevron_forward, color: Colors.grey, size: 16),
                          ],
                        ),
                      ),
                    ),

                    Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                      indent: 58,
                    ),

                    // Request Permission Button
                    BouncyTap(
                      onTap: () async {
                        final granted = await NotificationService().requestPermissions();
                        if (context.mounted) {
                          showCupertinoDialog(
                            context: context,
                            builder: (ctx) => CupertinoAlertDialog(
                              title: Text(granted ? 'Đã cấp quyền' : 'Chưa cấp quyền'),
                              content: Text(granted
                                  ? 'Ứng dụng đã có đầy đủ quyền gửi thông báo nhắc nhở.'
                                  : 'Vui lòng vào Cài đặt iOS > Thông báo > Cho phép thông báo.'),
                              actions: [
                                CupertinoDialogAction(
                                  child: const Text('OK'),
                                  onPressed: () => Navigator.of(ctx).pop(),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF34C759), Color(0xFF30E8BD)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(CupertinoIcons.checkmark_shield_fill, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 14),
                            const Expanded(
                              child: Text(
                                'Kiểm tra quyền thông báo iOS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: IOSTheme.primaryBlue,
                                ),
                              ),
                            ),
                            const Icon(CupertinoIcons.chevron_forward, color: Colors.grey, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Section 3: App Info
              _buildSectionHeader('THÔNG TIN ỨNG DỤNG', isDark),
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Phiên bản', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text('1.0.0 (Build 1)', style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    Divider(
                      height: 1,
                      color: isDark ? const Color(0xFF26293B) : const Color(0xFFE5E7EB),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Nền tảng', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          Text('Flutter & iOS 18 Design', style: TextStyle(fontSize: 15, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
}
