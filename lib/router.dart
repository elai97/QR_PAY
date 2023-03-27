import 'package:flutter/material.dart';

import 'ui/screens/home.dart';
import 'ui/screens/login.dart';

final Map<String, WidgetBuilder> routes = {
  HomePage.routeName: (context) => const HomePage(),
  LoginPage.routeName: (context) => const LoginPage(),
};

class AppRouter {
  static Route onGenerateRoute(RouteSettings settings) {
    // print('Route: ${settings.name}');
    switch (settings.name) {
      case '/':
        return HomePage.route();
      default:
        return _errorRoute();
    }
  }

  static Route _errorRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/error'),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: const Center(
          child: Text('Something went wrong!'),
        ),
      ),
    );
  }
}
