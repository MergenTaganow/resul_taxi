import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:taxi_service/core/network/api_client.dart';

import '../../domain/entities/queued_request.dart';
import '../di/injection.dart';

class QueuedRequestsService {

  Future<void> queueRequest(QueuedRequest request) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> existingQueue = prefs.getStringList('request_queue') ?? [];
    existingQueue.add(jsonEncode(request.toJson()));
    await prefs.setStringList('request_queue', existingQueue);
  }

  Future<void> retryQueuedRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> queue = prefs.getStringList('request_queue') ?? [];

    final List<String> remainingQueue = [];

    for (final requestJson in queue) {
      final request = QueuedRequest.fromJson(jsonDecode(requestJson));
      try {
        final response = await getIt<ApiClient>().completeOrder(
          requestId: request.requestId,
          priceTotal: request.priceTotal,
          roadDetails: request.roadDetails,
        );
        if (response.statusCode != 200) {
          remainingQueue.add(requestJson); // keep if failed
        }
      } catch (_) {
        remainingQueue.add(requestJson); // keep if exception
      }
    }

    await prefs.setStringList('request_queue', remainingQueue);
  }
}

