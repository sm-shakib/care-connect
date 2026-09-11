part of 'document_reupload_cubit.dart';

enum DocumentReuploadStatus { initial, submitting, success, failure }

class DocumentReuploadState extends Equatable {
  const DocumentReuploadState({
    this.status = DocumentReuploadStatus.initial,
    this.uploadedDocuments = const {},
    this.submitAttempted = false,
    this.errorMessage,
  });

  final DocumentReuploadStatus status;
  final Map<CaregiverDocumentType, PlatformFile> uploadedDocuments;
  final bool submitAttempted;
  final String? errorMessage;

  bool get isValid => 
      uploadedDocuments.length == CaregiverDocumentType.values.length;

  bool get isSubmitting => status == DocumentReuploadStatus.submitting;
  bool get isSuccess => status == DocumentReuploadStatus.success;

  DocumentReuploadState copyWith({
    DocumentReuploadStatus? status,
    Map<CaregiverDocumentType, PlatformFile>? uploadedDocuments,
    bool? submitAttempted,
    String? errorMessage,
  }) {
    return DocumentReuploadState(
      status: status ?? this.status,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      submitAttempted: submitAttempted ?? this.submitAttempted,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, uploadedDocuments, submitAttempted, errorMessage];
}
