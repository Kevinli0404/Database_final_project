import 'package:flutter/material.dart';
import 'package:database_final_project/page/login_page.dart';
import 'package:database_final_project/provider/shared_state.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SharedState()),
          ChangeNotifierProvider(create: (_) => ServerAPI()),
        ],
        child: const MyApp(),
      ),
    );
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // 全局導航鍵
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
    );
  }
}
