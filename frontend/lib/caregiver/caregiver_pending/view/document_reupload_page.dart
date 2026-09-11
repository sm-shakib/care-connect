import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/caregiver_signup/caregiver_signup.dart';
import 'package:frontend/core/widgets/care_connect_app_bar.dart';
import 'package:frontend/core/widgets/document_upload_tile.dart';
import 'package:frontend/core/widgets/primary_pill_button.dart';
import 'package:frontend/l10n/l10n.dart';
import 'package:frontend/theme/app_colors.dart';
import '../cubit/document_reupload_cubit.dart';

class DocumentReuploadPage extends StatelessWidget {
  const DocumentReuploadPage({super.key});

  static Route<bool> route() {
    return MaterialPageRoute<bool>(
      builder: (_) => BlocProvider(
        create: (_) => DocumentReuploadCubit(),
        child: const DocumentReuploadPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocConsumer<DocumentReuploadCubit, DocumentReuploadState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Documents re-submitted successfully!')),
          );
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        final cubit = context.read<DocumentReuploadCubit>();

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                CareConnectAppBar(
                  onBack: () => Navigator.pop(context),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Re-upload Documents',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkTeal,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please re-upload all required documents. Make sure they are clear and up-to-date.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        for (final type in CaregiverDocumentType.values) ...[
                          DocumentUploadTile(
                            documentTypeLabel: type.label(context),
                            fileName: state.uploadedDocuments[type]?.name,
                            onFilePicked: (file) => cubit.documentPicked(type, file),
                          ),
                          const SizedBox(height: 14),
                        ],
                        if (state.submitAttempted && !state.isValid) ...[
                          const SizedBox(height: 4),
                          Text(
                            l10n.uploadAllDocumentsError,
                            style: const TextStyle(fontSize: 13, color: Colors.red),
                          ),
                        ],
                        if (state.errorMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            state.errorMessage!,
                            style: const TextStyle(fontSize: 13, color: Colors.red),
                          ),
                        ],
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
                  child: PrimaryPillButton(
                    label: 'Submit for Re-verification',
                    icon: Icons.check,
                    isLoading: state.isSubmitting,
                    onPressed: cubit.submit,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
