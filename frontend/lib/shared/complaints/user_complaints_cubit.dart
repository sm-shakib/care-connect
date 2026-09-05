import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/repositories/complaint_repository.dart';
import 'user_complaint_model.dart';

enum UserComplaintsStatus { initial, loading, success, failure }

class UserComplaintsState extends Equatable {
  const UserComplaintsState({
    this.status = UserComplaintsStatus.initial,
    this.complaints = const [],
    this.errorMessage,
  });

  final UserComplaintsStatus status;
  final List<UserComplaint> complaints;
  final String? errorMessage;

  UserComplaintsState copyWith({
    UserComplaintsStatus? status,
    List<UserComplaint>? complaints,
    String? errorMessage,
  }) {
    return UserComplaintsState(
      status: status ?? this.status,
      complaints: complaints ?? this.complaints,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, complaints, errorMessage];
}

class UserComplaintsCubit extends Cubit<UserComplaintsState> {
  UserComplaintsCubit({ComplaintRepository? repository, this.isCaregiverMode = false})
      : _repository = repository ?? ComplaintRepository(),
        super(const UserComplaintsState());

  final ComplaintRepository _repository;
  final bool isCaregiverMode;

  Future<void> loadComplaints() async {
    emit(state.copyWith(status: UserComplaintsStatus.loading));
    try {
      final List<Map<String, dynamic>> results;
      if (isCaregiverMode) {
        results = await _repository.getCaregiverComplaints();
      } else {
        results = await _repository.getMyComplaints();
      }
      
      final complaints = results
          .map((json) => UserComplaint.fromJson(json))
          .toList();
      
      emit(state.copyWith(
        status: UserComplaintsStatus.success,
        complaints: complaints,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: UserComplaintsStatus.failure,
        errorMessage: 'Unable to load reports.',
      ));
    }
  }

  Future<void> respondToComplaint(String complaintId, String explanation) async {
    try {
      await _repository.respondToComplaint(int.parse(complaintId), explanation);
      await loadComplaints(); // Refresh list
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Failed to submit response.'));
    }
  }
}
