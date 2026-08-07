import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../cubit/caregiver_review_state.dart';

/// Fixed bottom sheet-style bar with an admin notes field and the three
/// decision actions.
///
/// Features a collapsible notes section to save vertical screen space.
class ReviewBottomActionBar extends StatefulWidget {
  const ReviewBottomActionBar({
    required this.notes,
    required this.isSubmitting,
    required this.onNotesChanged,
    required this.onApprove,
    required this.onRequestDocs,
    required this.onReject,
    super.key,
  });

  final String notes;
  final bool isSubmitting;
  final ValueChanged<String> onNotesChanged;
  final VoidCallback onApprove;
  final VoidCallback onRequestDocs;
  final VoidCallback onReject;

  @override
  State<ReviewBottomActionBar> createState() => _ReviewBottomActionBarState();
}

class _ReviewBottomActionBarState extends State<ReviewBottomActionBar> {
  bool _isExpanded = false;

  bool get _overLimit => widget.notes.length > kAdminNotesMaxLength;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          top: BorderSide(color: AppColors.outlineVariantLight),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 512),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        'Administrative Comments',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariantLight,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () =>
                          setState(() => _isExpanded = !_isExpanded),
                      icon: Icon(
                        _isExpanded ? Icons.expand_more : Icons.expand_less,
                        color: AppColors.onSurfaceVariantLight,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                if (_isExpanded) ...[
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      TextField(
                        onChanged: widget.onNotesChanged,
                        minLines: 2,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: 'Enter notes for this application...',
                          hintStyle:
                              TextStyle(color: AppColors.outlineVariantLight),
                          filled: true,
                          fillColor: AppColors.surfaceContainerLowLight,
                          contentPadding: const EdgeInsets.fromLTRB(
                            12,
                            12,
                            12,
                            28,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariantLight,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.outlineVariantLight,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: AppColors.primaryLight,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 12,
                        child: Text(
                          '${widget.notes.length}/$kAdminNotesMaxLength',
                          style: TextStyle(
                            fontSize: 14,
                            color: _overLimit
                                ? AppColors.errorLight
                                : AppColors.outlineVariantLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: widget.isSubmitting || _overLimit
                              ? null
                              : widget.onApprove,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryLight,
                            foregroundColor: AppColors.onPrimaryLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.check_circle),
                          label: const Text(
                            'Approve Application',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: OutlinedButton.icon(
                          onPressed:
                              widget.isSubmitting ? null : widget.onRequestDocs,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primaryLight,
                            side: BorderSide(
                              color: AppColors.primaryLight,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.history_edu),
                          label: const Text(
                            'Request Docs',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed:
                              widget.isSubmitting ? null : widget.onReject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.errorLight,
                            foregroundColor: AppColors.onErrorLight,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          icon: const Icon(Icons.cancel),
                          label: const Text(
                            'Reject',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
