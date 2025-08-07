import 'package:get_it/get_it.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'package:taxi_service/core/network/socket_client.dart';
import 'package:taxi_service/core/services/additional_settings_service.dart';
import 'package:taxi_service/core/services/sound_service.dart';
import 'package:taxi_service/core/services/push_notification_service.dart';
import 'package:taxi_service/core/services/profile_service.dart';
import 'package:taxi_service/core/services/gps_service.dart';
import 'package:taxi_service/core/services/settings_service.dart';
import 'package:taxi_service/core/services/location_warning_service.dart';
import 'package:taxi_service/core/services/location_district_service.dart';
import 'package:taxi_service/core/services/taxometer_service.dart';
import 'package:taxi_service/core/services/connectivity_service.dart';
import 'package:taxi_service/domain/repositories/auth_repository.dart';
import 'package:taxi_service/data/repositories/auth_repository_impl.dart';
import 'package:taxi_service/domain/repositories/order_repository.dart';
import 'package:taxi_service/data/repositories/order_repository_impl.dart';
import 'package:taxi_service/presentation/blocs/auth/auth_bloc.dart';
import 'package:taxi_service/presentation/blocs/order/order_bloc.dart';
import 'package:taxi_service/presentation/blocs/notifications/notifications_bloc.dart';
import 'package:taxi_service/presentation/blocs/messages/messages_bloc.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Services
  getIt.registerLazySingleton(() => ApiClient());
  getIt.registerLazySingleton(() => SocketClient());
  getIt.registerLazySingleton(() => SoundService());
  getIt.registerLazySingleton(() => ProfileService());
  getIt.registerLazySingleton(() => GpsService());
  getIt.registerLazySingleton(() => SettingsService());
  getIt.registerLazySingleton(() => LocationWarningService());
  getIt.registerLazySingleton(() => LocationDistrictService());
  getIt.registerLazySingleton(() => TaxometerService());
  getIt.registerLazySingleton(() => ConnectivityService());
  getIt.registerLazySingleton(() => AdditionalSettingsService());

  // Initialize Services
  await getIt<SettingsService>().initialize();
  await getIt<LocationWarningService>().initialize();
  await getIt<LocationDistrictService>().initialize();
  await getIt<ConnectivityService>().initialize();

  // Initialize socket client connectivity monitoring
  getIt<SocketClient>().initializeConnectivityMonitoring();

  // Initialize push notifications
  await PushNotificationService.initialize();

  // Network

  // Set up token refresh callback
  final apiClient = getIt<ApiClient>();
  final socketClient = getIt<SocketClient>();
  apiClient.setTokenRefreshCallback(socketClient.onTokenRefreshed);

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<ApiClient>(), getIt<SocketClient>()),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      getIt<ApiClient>(),
      getIt<SocketClient>(),
    ),
  );

  // BLoCs
  getIt.registerFactory(() {
    print('[DI] Creating AuthBloc');
    final authRepository = getIt<AuthRepository>();
    print('[DI] AuthRepository obtained: ${authRepository.runtimeType}');
    return AuthBloc(authRepository);
  });
  getIt.registerFactory(() => OrderBloc(getIt<OrderRepository>()));
  getIt.registerFactory(
      () => NotificationsBloc(getIt<SocketClient>(), getIt<ApiClient>()));
  getIt.registerFactory(
      () => MessagesBloc(getIt<SocketClient>(), getIt<ApiClient>()));
}
