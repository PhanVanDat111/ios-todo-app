import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/todo_provider.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';
import 'theme/ios_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Local Notifications Service
  await NotificationService().initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: Consumer<TodoProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'iOS Reminders',
            debugShowCheckedModeBanner: false,
            theme: IOSTheme.lightTheme,
            darkTheme: IOSTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
