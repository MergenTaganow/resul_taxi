import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/domain/entities/order.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_bloc.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_event.dart';
import 'package:taxi_service/presentation/blocs/order/order_bloc.dart';
import 'package:taxi_service/presentation/blocs/order/order_event.dart';
import 'package:taxi_service/presentation/blocs/order/order_state.dart';
import 'package:taxi_service/domain/entities/commute_type.dart';
import 'package:taxi_service/domain/repositories/order_repository.dart';
import 'package:taxi_service/core/mixins/location_warning_mixin.dart';

import '../../core/di/injection.dart';
import '../../core/services/taxometer_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with LocationWarningMixin {
  @override
  void initState() {
    super.initState();
    // Fetch profile when home screen loads
    context.read<AuthBloc>().add(const AuthEvent.fetchProfile());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.primary.withOpacity(0.95),
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.local_taxi,
              color: theme.colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Resul Taxi',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(
                Icons.logout,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              onPressed: () {
                context.read<AuthBloc>().add(const AuthEvent.logout());
              },
            ),
          ),
        ],
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          state.maybeWhen(
            error: (message) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(message),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            orElse: () {},
          );
        },
        builder: (context, state) {
          return state.maybeWhen(
            orderReceived: (order, commuteTime) => _buildIncomingOrder(context, order),
            orderAccepted: (order, freeOrder, commuteTime) =>
                _buildOrderTracking(context, order, false),
            orderInProgress: (order, commuteTime) => _buildOrderTracking(context, order, true),
            orElse: () => _buildWaitingState(context),
          );
        },
      ),
    );
  }

  Widget _buildWaitingState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.local_taxi,
              size: 64,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Ожидание заказов',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Вы будете уведомлены, когда поступит новый заказ',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Онлайн',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIncomingOrder(BuildContext context, Order order) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header with notification
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Новый заказ!',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Нажмите для просмотра деталей',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Order details card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Details',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildOrderDetails(context, order),
                  const SizedBox(height: 32),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<OrderBloc>().add(
                                  OrderEvent.rejectOrder(order.id),
                                );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Отклонить',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            // Show commute type selection dialog
                            final commuteTime = await showDialog<String>(
                              context: context,
                              barrierDismissible: false,
                              builder: (ctx) => _CommuteTypeDialog(order: order),
                            );
                            if (commuteTime != null) {
                              context.read<OrderBloc>().add(
                                    OrderEvent.acceptOrder(order.id, false, order,
                                        commuteTime: commuteTime),
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Принять',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTracking(BuildContext context, Order order, bool isInProgress) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isInProgress
                    ? [
                        theme.colorScheme.secondary,
                        theme.colorScheme.secondary.withOpacity(0.8),
                      ]
                    : [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withOpacity(0.7),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isInProgress ? theme.colorScheme.secondary : theme.colorScheme.primary)
                      .withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isInProgress ? Icons.directions_car : Icons.play_arrow,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isInProgress ? 'Поездка в процессе' : 'Готов к началу',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        isInProgress
                            ? 'Осторожно ведите к месту назначения'
                            : 'Начните поездку, когда будете готовы',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Order details card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Детали поездки',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildOrderDetails(context, order),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isInProgress) {
                          context.read<OrderBloc>().add(
                                OrderEvent.completeOrder(order.id, order),
                              );
                        } else {
                          context.read<OrderBloc>().add(
                                OrderEvent.startOrder(order.id, order),
                              );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isInProgress ? Colors.green : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isInProgress ? 'Завершить поездку' : 'Начать поездку',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Trip statistics (only show when in progress)
          if (isInProgress) ...[
            const SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.analytics,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Trip Statistics',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildStatisticRow(
                      context,
                      Icons.timer,
                      'Duration',
                      '32 min',
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticRow(
                      context,
                      Icons.speed,
                      'Distance',
                      '5.8 km',
                    ),
                    const SizedBox(height: 16),
                    _buildStatisticRow(
                      context,
                      Icons.attach_money,
                      'Current Fare',
                      '\$15.75',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderDetails(BuildContext context, Order order) {
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildDetailRow(
          context,
          Icons.person,
          'Order ID',
          order.id.toString(),
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          Icons.phone,
          'Phone',
          order.phonenumber ?? '-',
        ),
        const SizedBox(height: 16),
        _buildDetailRow(
          context,
          Icons.location_on,
          'Pickup',
          order.requestedAddress ?? '-',
        ),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
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
      final repo = RepositoryProvider.of<OrderRepository>(context, listen: false);
      final types = await repo.getCommuteTypes();
      getIt<TaxometerService>().setTimeForDrivingToWaiting(
          int.parse(types.firstWhere((e) => e.key == "commute_for_waiting").value));
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      backgroundColor: theme.colorScheme.surface,
      contentPadding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
      titlePadding: const EdgeInsets.fromLTRB(32, 32, 32, 0),
      title: Row(
        children: [
          Icon(Icons.local_taxi, color: theme.colorScheme.primary, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Select Arriving Time Type',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      content: _loading
          ? const SizedBox(height: 120, child: Center(child: CircularProgressIndicator()))
          : _error != null
              ? SizedBox(
                  height: 120,
                  child: Center(child: Text(_error!, style: const TextStyle(color: Colors.red))))
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...?_commuteTypes?.map((type) => type.key == 'commute_for_waiting'
                        ? Container()
                        : RadioListTile<String>(
                            title: Text(type.description),
                            value: type.key,
                            groupValue: _selectedCommuteKey,
                            onChanged: (val) => setState(() => _selectedCommuteKey = val),
                          )),
                  ],
                ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _selectedCommuteKey == null
              ? null
              : () {
                  final commuteTime =
                      _commuteTypes!.firstWhere((type) => type.key == _selectedCommuteKey).value;
                  Navigator.of(context).pop(commuteTime);
                },
          child: const Text('Select'),
        ),
      ],
    );
  }
}
