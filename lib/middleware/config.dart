
enum PolicyType { production, staging }

enum LoginState { none, loading, success, fail }

enum ActivityState { none, loading, success, fail }

class UserRole {
  static String guest = "guest";
  static String admin = "admin";
}

class Pages {
  static const int dashboard = 0;
  static const int policyDiff = 1;
  static const int users = 2;
  static const int eventLogs = 3;
}

class Configuration {
  final middlewareHost = "http://localhost:8000"; //todo: change to prod
  final KEY_AUTH = "Authorization";
}

enum LoadingProgress { none, loading, success, fail }

// class Responsive extends StatelessWidget {
//   final Widget mobile, tablet, desktop;
//
//   const Responsive(
//       {Key? key,
//       required this.mobile,
//       required this.tablet,
//       required this.desktop})
//       : super(key: key);
//
//   static bool isMobile(BuildContext context) =>
//       MediaQuery.of(context).size.width < 650;
//
//   static bool isWideScreen(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 790;
//
//   static bool isTablet(BuildContext context) =>
//       MediaQuery.of(context).size.width < 1100 && !isMobile(context);
//
//   static bool isDesktop(BuildContext context) =>
//       MediaQuery.of(context).size.width >= 1100;
//
//   @override
//   Widget build(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       if (isDesktop(context)) {
//         return desktop;
//       } else if (isTablet(context)) {
//         return tablet;
//       } else {
//         return mobile;
//       }
//     });
//   }
// }
