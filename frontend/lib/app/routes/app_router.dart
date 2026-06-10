import 'package:flutter/material.dart';
import '../../data/models/order.dart';
import '../../data/models/product.dart';
import '../../features/auth/auth_screen.dart';
import '../../features/cart/checkout_screen.dart';
import '../../features/cart/order_success_screen.dart';
import '../../features/cart/payment_methods_screen.dart';
import '../../features/home/category_list_screen.dart';
import '../../features/home/subcategories_screen.dart';
import '../../features/home/filters_screen.dart';
import '../../features/home/brand_selector_screen.dart';
import '../../features/product/product_detail_screen.dart';
import '../../features/profile/my_orders_screen.dart';
import '../../features/profile/order_detail_screen.dart';
import '../../features/profile/settings_screen.dart';
import '../../features/profile/shipping_addresses_screen.dart';
import '../../features/visual_search/visual_search_screen.dart';
import '../../features/visual_search/visual_search_camera_screen.dart';
import '../../features/visual_search/visual_search_crop_screen.dart';
import '../../features/visual_search/visual_search_finding_screen.dart';
import '../../features/product/reviews_screen.dart';
import '../navigation/main_shell_screen.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.auth:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case AppRoutes.main:
        return MaterialPageRoute(builder: (_) => const MainShellScreen());
      case AppRoutes.category:
        final args = settings.arguments;
        if (args is Map<String, dynamic>) {
          final id = args['id'] as String?;
          final name = args['name'] as String? ?? 'Category';
          return MaterialPageRoute(builder: (_) => CategoryListScreen(categoryId: id, categoryName: name));
        } else {
          final name = args as String? ?? 'Sale';
          return MaterialPageRoute(builder: (_) => CategoryListScreen(categoryName: name));
        }
      case AppRoutes.subcategories:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => SubcategoriesScreen(
          parentId: args?['id'],
          parentName: args?['name'],
        ));
      case AppRoutes.product:
        final product = settings.arguments as Product;
        return MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product));
      case AppRoutes.checkout:
        return MaterialPageRoute(builder: (_) => const CheckoutScreen());
      case AppRoutes.payment:
        return MaterialPageRoute(builder: (_) => const PaymentMethodsScreen());
      case AppRoutes.orderSuccess:
        return MaterialPageRoute(builder: (_) => const OrderSuccessScreen());
      case AppRoutes.orderSuccess2:
        return MaterialPageRoute(builder: (_) => const OrderSuccessScreen2());
      case AppRoutes.orders:
        return MaterialPageRoute(builder: (_) => const MyOrdersScreen());
      case AppRoutes.orderDetail:
        final order = settings.arguments as Order;
        return MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order));
      case AppRoutes.filters:
        return MaterialPageRoute(builder: (_) => const FiltersScreen());
      case AppRoutes.brands:
        return MaterialPageRoute(builder: (_) => const BrandSelectorScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case AppRoutes.shippingAddresses:
        return MaterialPageRoute(builder: (_) => const ShippingAddressesScreen());
      case AppRoutes.visualSearch:
        return MaterialPageRoute(builder: (_) => const VisualSearchScreen());
      case AppRoutes.visualSearchCamera:
        return MaterialPageRoute(builder: (_) => const VisualSearchCameraScreen());
      case AppRoutes.visualSearchCrop:
        return MaterialPageRoute(builder: (_) => const VisualSearchCropScreen());
      case AppRoutes.visualSearchFinding:
        return MaterialPageRoute(builder: (_) => const VisualSearchFindingScreen());
      case AppRoutes.reviews:
        final productId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => ReviewsScreen(productId: productId));
      default:
        return MaterialPageRoute(builder: (_) => const AuthScreen());
    }
  }
}
