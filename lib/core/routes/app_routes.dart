import 'package:flutter/material.dart';

import '../../features/about/about_app_screen.dart';
import '../../features/about/about_project_screen.dart';
import '../../features/admin/add_market_screen.dart';
import '../../features/admin/edit_market_screen.dart';
import '../../features/admin/manage_markets_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/commodity/screens/categories_screen.dart';
import '../../features/commodity/screens/commodity_details_screen.dart';
import '../../features/commodity/screens/commodity_list_screen.dart';
import '../../features/commodity/screens/price_comparison_screen.dart';
import '../../features/contact/contact_developer_screen.dart';
import '../../features/home/main_navigation_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../models/commodity.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String commodityList = '/commodity-list';
  static const String commodityDetails = '/commodity-details';
  static const String comparePrices = '/compare-prices';
  static const String search = '/search';
  static const String favourites = '/favourites';
  static const String settings = '/settings';
  static const String addMarket = '/add-market';
  static const String manageMarkets = '/manage-markets';
  static const String editMarket = '/edit-market';
  static const String aboutApp = '/about-app';
  static const String aboutProject = '/about-project';
  static const String contactDeveloper = '/contact-developer';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationScreen(),
          settings: settings,
        );
      case categories:
        return MaterialPageRoute(
          builder: (_) => const CategoriesScreen(),
          settings: settings,
        );
      case commodityList:
        final category = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => CommodityListScreen(initialCategory: category),
          settings: settings,
        );
      case commodityDetails:
        final commodity = settings.arguments as Commodity;
        return MaterialPageRoute(
          builder: (_) => CommodityDetailsScreen(commodity: commodity),
          settings: settings,
        );
      case comparePrices:
        final commodity = settings.arguments as Commodity?;
        return MaterialPageRoute(
          builder: (_) => PriceComparisonScreen(initialCommodity: commodity),
          settings: settings,
        );
      case search:
        return MaterialPageRoute(
          builder: (_) => const CommodityListScreen(),
          settings: settings,
        );
      case addMarket:
        return MaterialPageRoute(
          builder: (_) => const AddMarketScreen(),
          settings: settings,
        );
      case manageMarkets:
        return MaterialPageRoute(
          builder: (_) => const ManageMarketsScreen(),
          settings: settings,
        );
      case editMarket:
        final commodity = settings.arguments as Commodity;
        return MaterialPageRoute(
          builder: (_) => EditMarketScreen(commodity: commodity),
          settings: settings,
        );
      case aboutApp:
        return MaterialPageRoute(
          builder: (_) => const AboutAppScreen(),
          settings: settings,
        );
      case aboutProject:
        return MaterialPageRoute(
          builder: (_) => const AboutProjectScreen(),
          settings: settings,
        );
      case contactDeveloper:
        return MaterialPageRoute(
          builder: (_) => const ContactDeveloperScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}