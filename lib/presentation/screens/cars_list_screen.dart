import 'package:flutter/material.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'dart:ui';

class CarsListScreen extends StatefulWidget {
  final int districtId;
  final String districtName;

  const CarsListScreen({
    Key? key,
    required this.districtId,
    required this.districtName,
  }) : super(key: key);

  @override
  State<CarsListScreen> createState() => _CarsListScreenState();
}

class _CarsListScreenState extends State<CarsListScreen> {
  List<dynamic> _cars = [];
  List<dynamic> _filteredCars = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  String _searchQuery = '';
  String _sortBy = 'queue_number'; // Default sort by queue number
  String _orderDirection = 'desc';

  // Pagination
  int _currentPage = 1;
  final int _limit = 20;
  bool _hasMoreData = true;

  @override
  void initState() {
    super.initState();
    _loadCars(refresh: true);
  }

  Future<void> _loadCars({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _hasMoreData = true;
        _cars.clear();
        _filteredCars.clear();
      });
    }

    if (!_hasMoreData && !refresh) return;

    setState(() {
      if (refresh) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final cars = await apiClient.getDistrictCars(
        widget.districtId,
        limit: _limit,
        page: _currentPage,
        orderDirection: _orderDirection,
        orderBy: _sortBy,
      );

      setState(() {
        if (refresh) {
          _cars = cars;
          _filteredCars = cars;
          _isLoading = false;
        } else {
          _cars.addAll(cars);
          _filteredCars.addAll(cars);
          _isLoadingMore = false;
        }
        _hasMoreData = cars.length == _limit;
        if (_hasMoreData) {
          _currentPage++;
        }
      });

      if (refresh) {
        _sortAndFilterCars();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _sortAndFilterCars() {
    List<dynamic> filtered = _cars.where((car) {
      final fullName =
          '${car['first_name'] ?? ''} ${car['last_name'] ?? ''}'.toLowerCase();
      final vehicleNumber =
          (car['vehicle_number'] ?? '').toString().toLowerCase();
      final vehicleType = (car['vehicle_type'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      return fullName.contains(query) ||
          vehicleNumber.contains(query) ||
          vehicleType.contains(query);
    }).toList();

    // Sort cars (client-side sorting for filtered results)
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'queue_number':
          final aQueue = a['queue_number'] ?? 999;
          final bQueue = b['queue_number'] ?? 999;
          return aQueue.compareTo(bQueue);
        case 'name':
          final aName = '${a['first_name'] ?? ''} ${a['last_name'] ?? ''}';
          final bName = '${b['first_name'] ?? ''} ${b['last_name'] ?? ''}';
          return aName.compareTo(bName);
        case 'vehicle_number':
          final aNumber = a['vehicle_number'] ?? '';
          final bNumber = b['vehicle_number'] ?? '';
          return aNumber.compareTo(bNumber);
        default:
          return 0;
      }
    });

    setState(() {
      _filteredCars = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _sortAndFilterCars();
  }

  void _onSortChanged(String sortBy) {
    setState(() {
      _sortBy = sortBy;
    });
    // Reload data with new sorting from server
    _loadCars(refresh: true);
  }

  void _onOrderDirectionChanged() {
    setState(() {
      _orderDirection = _orderDirection == 'desc' ? 'asc' : 'desc';
    });
    // Reload data with new order direction from server
    _loadCars(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF232526), Color(0xFF414345)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              _FrostedBar(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Список машин',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.districtName,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: _isLoading ? null : _loadCars,
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                  size: 64,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Ошибка загрузки',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadCars,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blueAccent,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Повторить'),
                                ),
                              ],
                            ),
                          )
                        : _filteredCars.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.local_taxi,
                                      color: Colors.white54,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _cars.isEmpty
                                          ? 'Нет машин в районе'
                                          : 'Ничего не найдено',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _cars.isEmpty
                                          ? 'В данный момент в районе нет зарегистрированных машин'
                                          : 'Попробуйте изменить поисковый запрос',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 20),
                                  itemCount: _filteredCars.length +
                                      (_hasMoreData ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == _filteredCars.length) {
                                      // Load more button
                                      return _LoadMoreButton(
                                        isLoading: _isLoadingMore,
                                        hasMoreData: _hasMoreData,
                                        onLoadMore: () =>
                                            _loadCars(refresh: false),
                                      );
                                    }
                                    final car = _filteredCars[index];
                                    return _CarCard(car: car);
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CarCard extends StatelessWidget {
  final Map<String, dynamic> car;

  const _CarCard({required this.car});

  @override
  Widget build(BuildContext context) {
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
                // Driver name and queue number
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                      child: const Icon(
                        Icons.person,
                        color: Colors.blueAccent,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${car['first_name'] ?? ''} ${car['last_name'] ?? ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Позиция в очереди: ${car['queue_number'] ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${car['id'] ?? 'N/A'}',
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Vehicle information
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        color: Colors.greenAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              car['vehicle_type'] ?? 'Неизвестная модель',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              car['vehicle_number'] ?? 'Номер не указан',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FrostedBar extends StatelessWidget {
  final Widget child;

  const _FrostedBar({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String currentValue;
  final Function(String) onChanged;

  const _SortChip({
    required this.label,
    required this.value,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentValue == value;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? Colors.white.withOpacity(0.3) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white54,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final bool hasMoreData;
  final VoidCallback onLoadMore;

  const _LoadMoreButton({
    required this.isLoading,
    required this.hasMoreData,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : hasMoreData
                ? ElevatedButton(
                    onPressed: onLoadMore,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Загрузить больше',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : const Text(
                    'Нет больше данных',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
      ),
    );
  }
}
