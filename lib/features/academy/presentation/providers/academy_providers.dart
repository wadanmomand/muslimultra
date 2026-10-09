import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/academy/data/academy_repository.dart';
import 'package:muslim_ultra/features/academy/domain/models/academy_program.dart';
import 'package:muslim_ultra/features/academy/domain/models/academy_teacher.dart';
import 'package:muslim_ultra/features/academy/domain/models/trial_booking_request.dart';

final academyRepositoryProvider = Provider<AcademyRepository>((ref) {
  return AcademyRepository();
});

final academyProgramsProvider =
    FutureProvider.autoDispose<AcademyFetchResult<List<AcademyProgram>>>((ref) async {
  final repo = ref.watch(academyRepositoryProvider);
  return repo.fetchPrograms();
});

final academyTeachersProvider =
    FutureProvider.autoDispose<AcademyFetchResult<List<AcademyTeacher>>>((ref) async {
  final repo = ref.watch(academyRepositoryProvider);
  return repo.fetchTeachers();
});

final selectedProgramForBookingProvider = StateProvider<AcademyProgram?>((ref) => null);

class TrialBookingNotifier extends StateNotifier<AsyncValue<bool?>> {
  final AcademyRepository _repository;

  TrialBookingNotifier(this._repository) : super(const AsyncData(null));

  Future<bool> submitBooking(TrialBookingRequest request) async {
    state = const AsyncLoading();
    final success = await _repository.bookTrial(request);
    if (success) {
      state = const AsyncData(true);
      return true;
    } else {
      state = AsyncError('Booking submission failed. Please check your connection.', StackTrace.current);
      return false;
    }
  }

  void reset() {
    state = const AsyncData(null);
  }
}

final trialBookingNotifierProvider =
    StateNotifierProvider.autoDispose<TrialBookingNotifier, AsyncValue<bool?>>((ref) {
  final repo = ref.watch(academyRepositoryProvider);
  return TrialBookingNotifier(repo);
});
