// model/rating_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class RatingManager {
  static const String _ratedOrdersKey = 'rated_orders';

  static Future<bool> isOrderRated(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final ratedOrders = prefs.getStringList(_ratedOrdersKey) ?? [];
    return ratedOrders.contains(orderId);
  }

  static Future<void> markOrderAsRated(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    final ratedOrders = prefs.getStringList(_ratedOrdersKey) ?? [];
    if (!ratedOrders.contains(orderId)) {
      ratedOrders.add(orderId);
      await prefs.setStringList(_ratedOrdersKey, ratedOrders);
    }
  }
}