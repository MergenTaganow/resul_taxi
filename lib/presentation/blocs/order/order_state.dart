import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:taxi_service/domain/entities/order.dart';

part 'order_state.freezed.dart';

@freezed
class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;
  const factory OrderState.loading() = _Loading;
  const factory OrderState.orderReceived(Order order, {String? commuteTime}) =
      _OrderReceived;
  const factory OrderState.orderAccepted(Order order, {String? commuteTime}) =
      _OrderAccepted;
  const factory OrderState.orderInProgress(Order order, {String? commuteTime}) =
      _OrderInProgress;
  const factory OrderState.orderCompleted(Order order) = _OrderCompleted;
  const factory OrderState.error(String message) = _Error;
}
