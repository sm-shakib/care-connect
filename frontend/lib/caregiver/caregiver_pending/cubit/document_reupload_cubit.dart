import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver/data/repositories/caregiver_repository.dart';
import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/core/repositories/auth_repository.dart';

part 'document_reupload_state.dart';

class DocumentReuploadCubit extends Cubit<DocumentReuploadState> {
  DocumentReuploadCubit({CaregiverRepository? repository})
      : _repository = repository ?? CaregiverRepository(),
        super(const DocumentReuploadState());

  final CaregiverRepository _repository;
  final AuthRepository _authRepository = AuthRepository();

  void documentPicked(CaregiverDocumentType type, PlatformFile file) {
    final updated = Map<CaregiverDocumentType, PlatformFile>.from(
      state.uploadedDocuments,
    )..[type] = file;
    emit(state.copyWith(uploadedDocuments: updated));
  }

  Future<void> submit() async {
    if (!state.isValid) {
      emit(state.copyWith(submitAttempted: true));
      return;
    }

    emit(state.copyWith(status: DocumentReuploadStatus.submitting));
    try {
      final documents = <Map<String, String>>[];
      for (final entry in state.uploadedDocuments.entries) {
        if (entry.value.bytes != null) {
          final docUrl = await _authRepository.uploadFile(
            entry.value.bytes!,
            entry.value.name,
          );
          if (docUrl != null) {
            documents.add({
              'document_type': entry.key.name,
              'document_url': docUrl,
            });
          }
        }
      }

      await _repository.reuploadDocuments(documents);
      emit(state.copyWith(status: DocumentReuploadStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: DocumentReuploadStatus.failure,
        errorMessage: 'Failed to re-upload documents. Please try again.',
      ));
    }
  }
}
