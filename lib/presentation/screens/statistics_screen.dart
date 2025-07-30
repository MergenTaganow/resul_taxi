import 'package:flutter/material.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'dart:ui';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  List<dynamic> _statistics = [];
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
      });
    }

    if (!_hasMoreData && !refresh) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final newData = await apiClient.getDriverStatistics(
        limit: _limit,
        page: _currentPage,
      );

      setState(() {
        if (refresh) {
          _statistics = newData;
        } else {
          _statistics.addAll(newData);
        }
        _isLoading = false;
        _hasMoreData = newData.length == _limit;
        if (_hasMoreData) {
          _currentPage++;
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final date = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Неизвестно';
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'accepted':
        return 'Принят';
      case 'completed':
        return 'Завершен';
      case 'cancelled':
        return 'Отменен';
      case 'pending':
        return 'Ожидает';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'accepted':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Статистика',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _loadStatistics(refresh: true),
          ),
        ],
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Summary Cards
                if (_statistics.isNotEmpty) ...[
                  Container(
                    height: 80,
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Всего',
                            value: _statistics.length.toString(),
                            icon: Icons.assignment,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Завершено',
                            value: _statistics
                                .where((item) => item['status'] == 'completed')
                                .length
                                .toString(),
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Принято',
                            value: _statistics
                                .where((item) => item['status'] == 'accepted')
                                .length
                                .toString(),
                            icon: Icons.pending,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Отменено',
                            value: _statistics
                                .where((item) => item['status'] == 'cancelled')
                                .length
                                .toString(),
                            icon: Icons.cancel,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                // Statistics List
                Expanded(
                  child: _isLoading && _statistics.isEmpty
                      ? const Center(child: CircularProgressIndicator())
                      : _error != null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Ошибка загрузки',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _error!,
                                    style:
                                        const TextStyle(color: Colors.white70),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: () =>
                                        _loadStatistics(refresh: true),
                                    child: const Text('Повторить'),
                                  ),
                                ],
                              ),
                            )
                          : _statistics.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Нет данных',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : RefreshIndicator(
                                  onRefresh: () =>
                                      _loadStatistics(refresh: true),
                                  child: ListView.builder(
                                    itemCount: _statistics.length +
                                        (_hasMoreData ? 1 : 0),
                                    itemBuilder: (context, index) {
                                      if (index == _statistics.length) {
                                        return _buildLoadMoreButton();
                                      }
                                      return _buildStatisticsCard(
                                          _statistics[index]);
                                    },
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(
                onPressed: () => _loadStatistics(),
                child: const Text('Загрузить еще'),
              ),
      ),
    );
  }

  Widget _buildStatisticsCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Заказ #${item['id']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(item['status'] ?? 'unknown')
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(item['status'] ?? 'unknown'),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _getStatusText(item['status'] ?? 'unknown'),
                        style: TextStyle(
                          color: _getStatusColor(item['status'] ?? 'unknown'),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                    'Адрес', item['requested_address'] ?? 'Не указан'),
                _buildInfoRow(
                    'Время', _formatTimestamp(item['created_at'] ?? '0')),
                if (item['price_total'] != null) ...[
                  _buildInfoRow('Стоимость', '${item['price_total']} TMT'),
                ],
                if (item['distance'] != null) ...[
                  _buildInfoRow('Расстояние', '${item['distance']} км'),
                ],
                if (item['duration'] != null) ...[
                  _buildInfoRow(
                      'Длительность', _formatDuration(item['duration'])),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(dynamic duration) {
    try {
      if (duration is int) {
        final hours = duration ~/ 3600;
        final minutes = (duration % 3600) ~/ 60;
        return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
      }
      return duration.toString();
    } catch (e) {
      return 'Неизвестно';
    }
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
