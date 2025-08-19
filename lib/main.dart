import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_theme.dart';
import 'providers/authProvider.dart';
import 'providers/controllers_provider.dart';
import 'providers/attendance_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/attendance/attendance_screen.dart';
import 'screens/leave/leave_request_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notification/notifications_screen.dart';
import 'services/notification_service.dart';
import 'screens/out_of_office_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider<SettingsProvider>(
          create: (context) => SettingsProvider(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, ControllersProvider>(
          create: (context) => ControllersProvider(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, authProvider, previous) =>
              previous ?? ControllersProvider(authProvider),
        ),
      ],
      child: Consumer<SettingsProvider?>(
        builder: (context, settingsProvider, child) {
          if (settingsProvider == null) {
            return MaterialApp(
              title: 'Woosh',
              debugShowCheckedModeBanner: false,
              theme: goldTheme.copyWith(
                textTheme: GoogleFonts.interTextTheme(),
              ),
              home: const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
            );
          }

          return MaterialApp(
            title: 'Woosh',
            debugShowCheckedModeBanner: false,
            theme: goldTheme.copyWith(
              textTheme: GoogleFonts.interTextTheme(),
            ),
            darkTheme: ThemeData(
              colorScheme:
                  goldColorScheme.copyWith(brightness: Brightness.dark),
              useMaterial3: true,
              textTheme: GoogleFonts.interTextTheme(),
            ),
            themeMode:
                settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/splash',
            routes: {
              '/splash': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/home': (context) => const HomeScreen(),
              '/attendance': (context) => const AttendanceScreen(),
              '/leave-request': (context) => const LeaveRequestScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/notifications': (context) => const NotificationsScreen(),
              '/out-of-office': (context) => const OutOfOfficeScreen(),
            },
          );
        },
      ),
    );
  }
}
