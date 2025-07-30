import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/domain/entities/commute_type.dart';

abstract class OrderRepository {
  Stream<Order> get orderStream;
  Future<void> acceptOrder(int orderId, {String? commuteTime});
  Future<void> rejectOrder(int orderId);
  Future<void> startOrder(int orderId);
  Future<void> completeOrder(int orderId);
  Future<List<Order>> getAvailableOrders(int districtId, {int page = 1, int limit = 20});
  Future<List<CommuteType>> getCommuteTypes();
}
