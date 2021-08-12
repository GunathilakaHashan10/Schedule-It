import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// import './screens/today_schedule_screen.dart';
import './screens/past_schedules_screen.dart';
import './screens/past_schedule_preview_screen.dart';
import './screens/about_screen.dart';
import './screens/auth_screen.dart';
import './screens/splash_screen.dart';
import './providers/schedule_provider.dart';
import './providers/auth_provider.dart';
import './providers/yourSchedule_provider.dart';
import './providers/connectivity_provider.dart';
import './providers/appVersion_provider.dart';

import './screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(ScheduleApp());
}

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ScheduleProvider>(
          create: (ctx) => ScheduleProvider('', '', '', []),
          update: (ctx, auth, previousSchedule) => ScheduleProvider(
            auth.token,
            auth.userId,
            previousSchedule == null ? null : previousSchedule.scheduleId,
            previousSchedule == null ? [] : previousSchedule.taskList,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, YourScheduleProvider>(
          create: (ctx) => YourScheduleProvider('', '', [], []),
          update: (ctx, auth, previousSchedule) => YourScheduleProvider(
            auth.token,
            auth.userId,
            previousSchedule == null ? [] : previousSchedule.pastSchedules,
            previousSchedule == null ? [] : previousSchedule.pastTaskList,
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, AppVersionProvider>(
          create: (ctx) => AppVersionProvider(''),
          update: (ctx, auth, previousVersion) =>
              AppVersionProvider(auth.token),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Schedule It',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              primaryColor: Colors.purple.shade400,
              accentColor: Colors.blue.shade900,
              errorColor: Colors.redAccent),
          home: auth.isAuth
              ? HomeScreen()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (ctx, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? SplashScreen()
                          : AuthScreen(),
                ),
          routes: {
            PastSchedulesScreen.routeName: (ctx) => PastSchedulesScreen(),
            PastSchedulePreviewScreen.routeName: (ctx) =>
                PastSchedulePreviewScreen(),
            AboutScreen.routeName: (ctx) => AboutScreen(),
          },
        ),
      ),
    );
  }
}
