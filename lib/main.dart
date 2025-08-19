import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:taxi_service/core/di/injection.dart';
import 'package:taxi_service/presentation/app.dart';
import 'package:taxi_service/domain/repositories/order_repository.dart';

void main() async {
  print('[MAIN] App starting...');
  WidgetsFlutterBinding.ensureInitialized();
  print('[MAIN] Flutter binding initialized');

  print('[MAIN] Configuring dependencies...');
  await configureDependencies();
  print('[MAIN] Dependencies configured');

  print('[MAIN] Running app...');
  FlutterForegroundTask.initCommunicationPort();
  runApp(
    RepositoryProvider<OrderRepository>(
      create: (_) => getIt<OrderRepository>(),
      child: const TaxiDriverApp(),
    ),
  );
  print('[MAIN] App started');
}
