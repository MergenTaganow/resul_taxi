part of 'districts_cubit.dart';

abstract class DistrictsState {}

class DistrictsInitial extends DistrictsState {}

class DistrictsLoading extends DistrictsState {}

class DistrictsLoaded extends DistrictsState {
  final List<dynamic> districts;
  DistrictsLoaded(this.districts);
}

class DistrictsError extends DistrictsState {
  final String message;
  DistrictsError(this.message);
}
