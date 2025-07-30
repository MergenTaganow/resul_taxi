import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_service/core/network/api_client.dart';
import 'package:get_it/get_it.dart';

part 'districts_state.dart';

class DistrictsCubit extends Cubit<DistrictsState> {
  DistrictsCubit() : super(DistrictsInitial());

  Future<void> fetchDistricts() async {
    emit(DistrictsLoading());
    try {
      final districts = await GetIt.I<ApiClient>().getDistricts();
      emit(DistrictsLoaded(districts));
    } catch (e) {
      emit(DistrictsError(e.toString()));
    }
  }
}
