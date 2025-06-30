import 'package:flutter/material.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/claims_dashboard/claims_dashboard.dart';
import '../presentation/camera_capture_interface/camera_capture_interface.dart';
import '../presentation/ai_damage_assessment/ai_damage_assessment.dart';
import '../presentation/claim_details_view/claim_details_view.dart';

class AppRoutes {
  static const String initial = '/';
  static const String loginScreen = '/login-screen';
  static const String claimsDashboard = '/claims-dashboard';
  static const String cameraCaptureInterface = '/camera-capture-interface';
  static const String aiDamageAssessment = '/ai-damage-assessment';
  static const String claimDetailsView = '/claim-details-view';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => LoginScreen(),
    loginScreen: (context) => LoginScreen(),
    claimsDashboard: (context) => ClaimsDashboard(),
    cameraCaptureInterface: (context) => CameraCaptureInterface(),
    aiDamageAssessment: (context) => AiDamageAssessment(),
    claimDetailsView: (context) => ClaimDetailsView(),
  };

  // Helper method to get route widget
  static Widget getRoute(String routeName) {
    final builder = routes[routeName];
    if (builder != null) {
      return builder(NavigatorKey.currentContext ??
          NavigatorKey.navigatorKey.currentContext!);
    }
    return LoginScreen(); // Default fallback
  }
}

// Global navigator key for navigation without context
class NavigatorKey {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  static BuildContext? get currentContext => navigatorKey.currentContext;
}
