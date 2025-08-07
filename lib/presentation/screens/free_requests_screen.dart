import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/domain/entities/commute_type.dart';
import 'package:taxi_service/domain/repositories/order_repository.dart';
import 'package:taxi_service/presentation/blocs/districts/districts_cubit.dart';
import 'package:taxi_service/presentation/widgets/order_card.dart';
import 'package:taxi_service/presentation/blocs/order/order_bloc.dart';
import 'package:taxi_service/presentation/blocs/order/order_event.dart';
import 'dart:ui';

class FreeRequestsScreen extends StatefulWidget {
  final int districtId;
  const FreeRequestsScreen({Key? key, required this.districtId})
      : super(key: key);

  @override
  State<FreeRequestsScreen> createState() => _FreeRequestsScreenState();
}

class _FreeRequestsScreenState extends State<FreeRequestsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Order> _orders = [];
  int _currentPage = 1;
  bool _isLoading = false;
  bool _hasMoreData = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFreeRequests();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreOrders();
      }
    }
  }

  Future<void> _fetchFreeRequests({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _currentPage = 1;
        _orders.clear();
        _hasMoreData = true;
        _error = null;
      });
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final newOrders = await getIt<OrderRepository>()
          .getAvailableOrders(widget.districtId, page: _currentPage);

      setState(() {
        if (isRefresh) {
          _orders = newOrders;
        } else {
          _orders.addAll(newOrders);
        }
        _hasMoreData =
            newOrders.length >= 20; // Using 20 items per page (API default)
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Ошибка загрузки заказов: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreOrders() async {
    if (!_hasMoreData || _isLoading) return;

    _currentPage++;
    await _fetchFreeRequests();
  }

  Future<void> _refreshOrders() async {
    await _fetchFreeRequests(isRefresh: true);
  }

  Future<void> _handleOrderAcceptance(BuildContext context, Order order) async {
    print('order: $order');
    // Show commute type dialog first
    final commuteTime = await showDialog<String>(
      context: context,
      builder: (ctx) => _CommuteTypeDialog(order: order),
    );

    if (commuteTime != null && context.mounted) {
      // Accept the order with the selected commute time
      context.read<OrderBloc>().add(
            OrderEvent.acceptOrder(order.id, true, order,
                commuteTime: commuteTime),
          );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Заказ успешно принят!'),
          backgroundColor: Colors.green,
        ),
      );

      // Reload the requests list to reflect the changes

      // Navigate back to previous screen
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Свободные заказы',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshOrders,
            child: _buildContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading && _orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
            SizedBox(height: 24),
            Text(
              'Загрузка заказов...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null && _orders.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ошибка загрузки',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _refreshOrders,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }

    if (_orders.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_taxi_outlined,
                  color: Colors.blue,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Нет свободных заказов',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'В настоящее время в этом районе нет свободных заказов.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _refreshOrders,
                icon: const Icon(Icons.refresh),
                label: const Text('Обновить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      itemCount: _orders.length + (_hasMoreData || _isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _orders.length) {
          // Loading indicator at the bottom
          return Container(
            padding: const EdgeInsets.all(20),
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }

        final order = _orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: OrderCard(
                  order: order,
                  onCardTap: () => _handleOrderAcceptance(context, order),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CommuteTypeDialog extends StatefulWidget {
  final Order order;
  const _CommuteTypeDialog({Key? key, required this.order}) : super(key: key);

  @override
  State<_CommuteTypeDialog> createState() => _CommuteTypeDialogState();
}

class _CommuteTypeDialogState extends State<_CommuteTypeDialog> {
  List<CommuteType>? _commuteTypes;
  String? _selectedCommuteKey;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCommuteTypes();
  }

  Future<void> _fetchCommuteTypes() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = getIt<OrderRepository>();
      final types = await repo.getCommuteTypes();
      setState(() {
        _commuteTypes = types;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load arriving time types.';
        _loading = false;
      });
    }
  }

  String _formatCommuteTime(String value) {
    try {
      final milliseconds = int.tryParse(value) ?? 0;
      final minutes = (milliseconds / 1000 / 60).round();

      if (minutes == 0) {
        return 'Менее 1 минуты';
      } else if (minutes == 1) {
        return '1 минута';
      } else if (minutes < 5) {
        return '$minutes минуты';
      } else {
        return '$minutes минут';
      }
    } catch (e) {
      return 'Время поездки';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.8,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.local_taxi,
                            color: Colors.green,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Принять заказ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Main content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Featured Address Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.orange,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                widget.order.requestedAddress ??
                                    'Адрес не указан',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Commute types section
                    _loading
                        ? Container(
                            height: 120,
                            child: const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                              ),
                            ),
                          )
                        : _error != null
                            ? Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.red.withOpacity(0.3)),
                                ),
                                child: Text(
                                  _error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Время прибытия:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  ...?_commuteTypes?.map((type) => Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 8),
                                        decoration: BoxDecoration(
                                          color: _selectedCommuteKey == type.key
                                              ? Colors.orange.withOpacity(0.2)
                                              : Colors.white.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: _selectedCommuteKey ==
                                                    type.key
                                                ? Colors.orange
                                                : Colors.white.withOpacity(0.1),
                                            width:
                                                _selectedCommuteKey == type.key
                                                    ? 2
                                                    : 1,
                                          ),
                                        ),
                                        child: RadioListTile<String>(
                                          selectedTileColor: Colors.orange,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
                                          title: Text(
                                            _formatCommuteTime(type.value),
                                            style: TextStyle(
                                              color: _selectedCommuteKey ==
                                                      type.key
                                                  ? Colors.orange.shade200
                                                  : Colors.white,
                                              fontWeight: _selectedCommuteKey ==
                                                      type.key
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                          value: type.key,
                                          groupValue: _selectedCommuteKey,
                                          onChanged: (val) => setState(
                                              () => _selectedCommuteKey = val),
                                          activeColor: Colors.orange,
                                        ),
                                      )),
                                ],
                              ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _selectedCommuteKey == null
                          ? null
                          : () {
                              final commuteTime = _commuteTypes!
                                  .firstWhere(
                                      (type) => type.key == _selectedCommuteKey)
                                  .value;

                              Navigator.of(context).pop(commuteTime);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.withOpacity(0.3),
                      ),
                      child: const Text(
                        'Принять заказ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
