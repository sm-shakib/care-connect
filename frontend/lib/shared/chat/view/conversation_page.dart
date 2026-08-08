import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/theme/app_colors.dart';

import '../cubit/conversation_cubit.dart';
import '../data/chat_repository.dart';
import '../models/chat_participant.dart';
import '../widgets/chat_composer_bar.dart';
import '../widgets/search_field.dart';
import '../widgets/themed_chat_bubble.dart';
import 'call_screen.dart';
import 'group_info_page.dart';
import 'media_gallery_page.dart';

/// A single conversation thread — text/photo/document/voice messages,
/// in-conversation search, and voice/video call entry points (1:1 calls
/// ring just the other person; group calls ring every other member).
/// Used identically from any role's Chats tab.
class ConversationPage extends StatelessWidget {
  const ConversationPage({
    super.key,
    required this.repository,
    required this.conversationId,
    required this.currentUser,
  });

  final ChatRepository repository;
  final String conversationId;
  final ChatParticipant currentUser;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConversationCubit(
        repository: repository,
        conversationId: conversationId,
        currentUser: currentUser,
      ),
      child: const _ConversationView(),
    );
  }
}

class _ConversationView extends StatefulWidget {
  const _ConversationView();

  @override
  State<_ConversationView> createState() => _ConversationViewState();
}

class _ConversationViewState extends State<_ConversationView> {
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _startCall(BuildContext context, {required bool isVideo}) {
    final cubit = context.read<ConversationCubit>();
    final conversation = cubit.state.conversation;
    if (conversation == null) return;

    if (conversation.isGroup) {
      final others =
          conversation.participants.where((p) => p.id != cubit.currentUser.id).toList();
      if (others.isEmpty) return;
      Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CallScreen(
            conversationId: cubit.conversationId,
            participants: others,
            groupTitle: conversation.displayTitle(cubit.currentUser.id),
            isVideo: isVideo,
          ),
        ),
      );
      return;
    }

    final other = conversation.otherParticipant(cubit.currentUser.id);
    if (other == null) return;
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => CallScreen(
          conversationId: cubit.conversationId,
          participants: [other],
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // backgroundColor: colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      body: SafeArea(
        child: BlocConsumer<ConversationCubit, ConversationState>(
          listener: (context, state) => _scrollToBottom(),
          builder: (context, state) {
            final cubit = context.read<ConversationCubit>();

            return Column(
              children: [
                _ConversationAppBar(state: state, onCall: _startCall),
                Divider(height: 1, color: colorScheme.outlineVariant.withValues(alpha: 0.3)),
                if (state.isSearching) _SearchResultBar(state: state),
                Expanded(
                  child: state.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          itemCount: state.messages.length,
                          itemBuilder: (context, index) {
                            final message = state.messages[index];
                            return ThemedChatBubble(
                              message: message,
                              showSenderName: state.isGroup,
                              highlighted: state.searchResultIds.contains(message.id),
                            );
                          },
                        ),
                ),
                ChatComposerBar(
                  onSendText: cubit.sendText,
                  onSendAttachments: cubit.sendAttachments,
                  onSendVoice: cubit.sendVoiceMessage,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ConversationAppBar extends StatelessWidget {
  const _ConversationAppBar({required this.state, required this.onCall});

  final ConversationState state;
  final void Function(BuildContext context, {required bool isVideo}) onCall;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final conversation = state.conversation;

    if (state.isSearching) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: colorScheme.primary),
              onPressed: () => context.read<ConversationCubit>().toggleSearch(open: false),
            ),
            Expanded(
              child: SearchField(
                hintText: 'Search in this conversation',
                autofocus: true,
                onChanged: (query) => context.read<ConversationCubit>().searchInConversation(query),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: conversation?.avatarColor ?? AppColors.paleMint,
            child: Icon(
              state.isGroup ? Icons.groups_2_outlined : Icons.person,
              size: 20,
              color: AppColors.darkTeal,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              state.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
          ),
          IconButton(
            icon: Icon(Icons.call_outlined, color: colorScheme.primary),
            onPressed: conversation == null ? null : () => onCall(context, isVideo: false),
          ),
          IconButton(
            icon: Icon(Icons.videocam_outlined, color: colorScheme.primary),
            onPressed: conversation == null ? null : () => onCall(context, isVideo: true),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: colorScheme.primary),
            color: const Color(0xFFFBFEFC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            onSelected: (value) {
              final cubit = context.read<ConversationCubit>();
              switch (value) {
                case 'search':
                  cubit.toggleSearch(open: true);
                  break;
                case 'media':
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => MediaGalleryPage(
                        repository: cubit.repository,
                        conversationId: cubit.conversationId,
                      ),
                    ),
                  );
                  break;
                case 'group_info':
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => GroupInfoPage(
                        repository: cubit.repository,
                        conversationId: cubit.conversationId,
                        currentUser: cubit.currentUser,
                      ),
                    ),
                  );
                  break;
                case 'mute':
                  cubit.toggleMute();
                  break;
                case 'delete':
                  _confirmAndDelete(context, cubit, state.title);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'search', child: Text('Search in conversation')),
              const PopupMenuItem(value: 'media', child: Text('Media & files')),
              if (state.isGroup)
                const PopupMenuItem(value: 'group_info', child: Text('Group info')),
              PopupMenuItem(
                value: 'mute',
                child: Text((conversation?.isMuted ?? false) ? 'Unmute notifications' : 'Mute notifications'),
              ),
              const PopupMenuItem(value: 'delete', child: Text('Delete chat')),
            ],
          ),
        ],
      ),
    );
  }
}

Future<void> _confirmAndDelete(BuildContext context, ConversationCubit cubit, String title) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete chat?'),
      content: Text('This removes "$title" and its message history from your device.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.warningRed),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  if (confirmed ?? false) {
    await cubit.deleteConversation();
    if (context.mounted) Navigator.of(context).maybePop();
  }
}

class _SearchResultBar extends StatelessWidget {
  const _SearchResultBar({required this.state});

  final ConversationState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (state.searchQuery.trim().isEmpty) return const SizedBox.shrink();

    final count = state.searchResultIds.length;
    return Container(
      width: double.infinity,
      // color: colorScheme.surfaceContainerLow,
      color: const Color(0xFFFBFEFC),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        count == 0 ? 'No matches' : '$count match${count == 1 ? '' : 'es'} found',
        style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
      ),
    );
  }
}
