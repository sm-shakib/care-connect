import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

import '../models/chat_participant.dart';

/// The "…is typing" bubble shown at the bottom of a thread, styled to sit
/// in the same visual language as a received `ThemedChatBubble`: same
/// surface color, same corner treatment, aligned to the left.
///
/// Three dots rise and fall in sequence off a single repeating controller.
/// [participants] is never empty when this is built — the conversation
/// view omits it entirely when nobody is typing, so there is no "zero
/// people" case to render.
class TypingIndicatorBubble extends StatefulWidget {
  const TypingIndicatorBubble({
    super.key,
    required this.participants,
    this.showName = false,
  });

  /// Everyone currently typing in this conversation, excluding the
  /// current user.
  final List<ChatParticipant> participants;

  /// Whether to name who is typing — set for groups, where "typing" alone
  /// doesn't say who, and left off for 1:1 chats where it's obvious.
  final bool showName;

  @override
  State<TypingIndicatorBubble> createState() => _TypingIndicatorBubbleState();
}

class _TypingIndicatorBubbleState extends State<TypingIndicatorBubble>
    with SingleTickerProviderStateMixin {
  static const _dotCount = 3;
  static const _dotSize = 7.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Vertical offset for dot [index] at the current tick. Each dot runs
  /// the same curve a third of a cycle behind the one before it.
  double _dotOffset(int index) {
    final phase = (_controller.value - index / (_dotCount * 2)) % 1.0;
    // Only the first third of each cycle animates; the rest is the pause
    // that makes the dots read as a wave rather than a jitter.
    if (phase > 0.33) return 0;
    final rise = 1 - (phase / 0.33 - 0.5).abs() * 2;
    return -3.0 * Curves.easeInOut.transform(rise);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 2, 12, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showName)
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 2),
                child: Text(
                  _label(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            Semantics(
              label: _label(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                    bottomLeft: Radius.circular(4),
                  ),
                ),
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _dotCount; i++)
                        Padding(
                          padding: EdgeInsets.only(left: i == 0 ? 0 : 5),
                          child: Transform.translate(
                            offset: Offset(0, _dotOffset(i)),
                            child: Container(
                              width: _dotSize,
                              height: _dotSize,
                              decoration: const BoxDecoration(
                                color: AppColors.darkTeal,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _label() => typingLabel(widget.participants);
}

/// "Adib is typing…" / "Adib and Shakib are typing…" / "3 people are
/// typing…" — also used for the conversation app bar's subtitle, hence
/// top-level rather than private to the bubble.
String typingLabel(List<ChatParticipant> participants) {
  switch (participants.length) {
    case 0:
      return '';
    case 1:
      return '${participants.first.name} is typing…';
    case 2:
      return '${participants[0].name} and ${participants[1].name} are typing…';
    default:
      return '${participants.length} people are typing…';
  }
}
