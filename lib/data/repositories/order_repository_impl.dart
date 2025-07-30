import 'dart:async';
import 'dart:convert';

import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/core/network/socket_client.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/domain/entities/commute_type.dart';
import 'package:taxi_service/domain/repositories/order_repository.dart';

class OrderRepositoryImpl implements OrderRepository {
  final ApiClient _apiClient;
  final SocketClient _socketClient;

  OrderRepositoryImpl(this._apiClient, this._socketClient);

  @override
  Stream<Order> get orderStream => _socketClient.orderStream.map(
        (data) => data,
      );

  @override
  Future<void> acceptOrder(int orderId, {String? commuteTime}) async {
    await _apiClient.acceptOrder(orderId, commuteTime: commuteTime);
  }

  @override
  Future<void> rejectOrder(int orderId) async {
    await _apiClient.updateOrderStatus(orderId.toString(), 'rejected');
  }

  @override
  Future<void> startOrder(int orderId) async {
    await _apiClient.updateOrderStatus(orderId.toString(), 'in_progress');
  }

  @override
  Future<void> completeOrder(int orderId) async {
    await _apiClient.updateOrderStatus(orderId.toString(), 'completed');
  }

  @override
  Future<List<Order>> getAvailableOrders(int districtId, {int page = 1, int limit = 20}) async {
    final data = await _apiClient.getAvailableOrders(districtId, page: page, limit: limit);
    return data.map<Order>((json) => Order.fromJson(json)).toList();
  }

  @override
  Future<List<CommuteType>> getCommuteTypes() async {
    return await _apiClient.getCommuteTypes();
  }
}
