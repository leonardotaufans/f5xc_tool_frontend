enum PolicyType { production, staging }

enum LoginState { none, loading, success, fail }

enum ActivityState { none, loading, success, fail }

class UserRole {
  static String guest = "guest";
  static String admin = "admin";
}

enum LoadBalancerType { cdn, tcp, http }

class Pages {
  static const int httpDashboard = 0;
  static const int tcpDashboard = 1;
  static const int cdnDashboard = 2;
  static const int policyDiff = 3;
  static const int users = 4;
  static const int eventLogs = 5;
}

class PagesName {
  static const httpDashboard = "HTTP Load Balancer";
  static const tcpDashboard = "TCP Load Balancer";
  static const cdnDashboard = "CDN Load Balancer";
  static const policyDiff = "Compare Policy";
  static const users = "User Management";
  static const eventLogs = "Event Logs";
  static const number = [
    httpDashboard,
    tcpDashboard,
    cdnDashboard,
    policyDiff,
    users,
    eventLogs
  ];
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
