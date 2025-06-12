import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:event_app/providers/auth_provider.dart';
import 'package:event_app/providers/event_provider.dart';
import 'package:event_app/providers/comment_provider.dart';
import 'package:event_app/providers/user_provider.dart';
import 'package:event_app/routes/app_router.dart';

// WEB:
// flutter run -d chrome --web-port=5000

// ANDROID:
// set up device
// flutter run --web-port=5000

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final GoRouter router = AppRouter.getRouter(context);
        return MaterialApp.router(
          title: 'Event Management App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          routerConfig: router,
        );
      },
    );
  }
}