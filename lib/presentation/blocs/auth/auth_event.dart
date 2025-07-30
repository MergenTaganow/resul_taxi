import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_event.freezed.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.login(String username, String password) = LoginEvent;
  const factory AuthEvent.logout() = LogoutEvent;
  const factory AuthEvent.appStarted() = AppStarted;
  const factory AuthEvent.fetchProfile() = FetchProfile;
}
