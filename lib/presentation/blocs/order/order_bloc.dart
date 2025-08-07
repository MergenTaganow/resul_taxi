import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/domain/repositories/order_repository.dart';
import 'package:taxi_service/presentation/blocs/order/order_event.dart';
import 'package:taxi_service/presentation/blocs/order/order_state.dart';
import 'package:taxi_service/presentation/screens/taxometer_screen.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _orderRepository;
  StreamSubscription<Order>? _orderSubscription;

  OrderBloc(this._orderRepository) : super(const OrderState.initial()) {
    on<OrderReceivedEvent>(
        (event, emit) => emit(OrderState.orderReceived(event.order)));
    on<AcceptOrderEvent>(_onAcceptOrder);
    on<RejectOrderEvent>(_onRejectOrder);
    on<StartOrderEvent>(_onStartOrder);
    on<CompleteOrderEvent>(_onCompleteOrder);

    _orderSubscription = _orderRepository.orderStream.listen(
      (order) {
        // if (order.status == OrderStatus.pending) {
        add(OrderEvent.orderReceived(order));
        // }
      },
    );
  }

  Future<void> _onAcceptOrder(
      AcceptOrderEvent event, Emitter<OrderState> emit) async {
    try {
      emit(const OrderState.loading());
      await _orderRepository.acceptOrder(event.orderId,
          commuteTime: event.commuteTime);
      emit(OrderState.orderAccepted(event.order, event.freeOrder,
          commuteTime: event.commuteTime));
      // Navigation logic will be handled in the UI (BlocListener)
    } catch (e) {
      emit(OrderState.error(e.toString()));
    }
  }

  Future<void> _onRejectOrder(
      RejectOrderEvent event, Emitter<OrderState> emit) async {
    try {
      emit(const OrderState.loading());
      await _orderRepository.rejectOrder(event.orderId);
      emit(const OrderState.initial());
    } catch (e) {
      emit(OrderState.error(e.toString()));
    }
  }

  Future<void> _onStartOrder(
      StartOrderEvent event, Emitter<OrderState> emit) async {
    try {
      emit(const OrderState.loading());
      await _orderRepository.startOrder(event.orderId);
      emit(OrderState.orderInProgress(event.order));
    } catch (e) {
      emit(OrderState.error(e.toString()));
    }
  }

  Future<void> _onCompleteOrder(
      CompleteOrderEvent event, Emitter<OrderState> emit) async {
    try {
      emit(const OrderState.loading());
      await _orderRepository.completeOrder(event.orderId);
      emit(OrderState.orderCompleted(event.order));
    } catch (e) {
      emit(OrderState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}
