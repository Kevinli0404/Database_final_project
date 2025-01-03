import 'package:flutter/material.dart';
import 'package:database_final_project/page/login_page.dart';
import 'package:database_final_project/provider/shared_state.dart';
import 'package:database_final_project/provider/api.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]).then((_) {
    // runApp(
    //   ChangeNotifierProvider(
    //     create: (_) => SharedState(),
    //     child: const MyApp(),
    //   ),
    // );
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
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
    );
  }
}
