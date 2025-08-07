import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taxi_service/domain/entities/order.dart';

part 'order_event.freezed.dart';

@freezed
class OrderEvent with _$OrderEvent {
  const factory OrderEvent.orderReceived(Order order) = OrderReceivedEvent;
  const factory OrderEvent.acceptOrder(int orderId, bool freeOrder, Order order,
      {required String commuteTime}) = AcceptOrderEvent;
  const factory OrderEvent.rejectOrder(int orderId) = RejectOrderEvent;
  const factory OrderEvent.startOrder(int orderId, Order order) =
      StartOrderEvent;
  const factory OrderEvent.completeOrder(int orderId, Order order) =
      CompleteOrderEvent;
}
