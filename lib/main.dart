import 'package:f5xc_tool/middleware/sql_query_helper.dart';
import 'package:f5xc_tool/model/auth_model.dart';
import 'package:f5xc_tool/screen/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screen/dashboard.dart';

bool _isAuthenticated = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterSecureStorage storage = FlutterSecureStorage();
  String auth = await storage.read(key: 'auth') ?? "";
  AuthResponse res = await SqlQueryHelper().verifyAuth(auth);
  _isAuthenticated = res.statusCode == 200;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(
                builder: (_) =>
                    _isAuthenticated ? DashboardScreen() : LoginScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => LoginScreen());
          case '/dashboard':
            return MaterialPageRoute(builder: (_) => DashboardScreen());
        }
        return null;
      },
      // routes: {
      //   "/": (context) => const LoginScreen(),
      //   "/dashboard": (context) => const DashboardScreen()
      // },
    );
  }
}
