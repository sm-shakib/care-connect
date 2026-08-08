import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/theme/app_colors.dart';

import '../cubit/chat_inbox_cubit.dart';
import '../data/chat_repository.dart';
import '../models/chat_participant.dart';
import '../widgets/conversation_tile.dart';
import '../widgets/search_field.dart';
import 'conversation_page.dart';
import 'new_conversation_page.dart';

/// The shared "Chats" tab — identical for elderly, caregiver, and family,
/// parameterized only by [currentUser] and [repository].
class ChatInboxPage extends StatelessWidget {
  const ChatInboxPage({
    super.key,
    required this.repository,
    required this.currentUser,
    this.showHeader = true,
  });

  final ChatRepository repository;
  final ChatParticipant currentUser;

  /// Whether to show the built-in "Chats" heading — turn off when this
  /// page is embedded as a tab under a shell that already has its own
  /// "Chats" app bar title (e.g. the caregiver/family dashboards).
  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatInboxCubit(repository: repository, currentUser: currentUser),
      child: _ChatInboxView(showHeader: showHeader),
    );
  }
}

class _ChatInboxView extends StatelessWidget {
  const _ChatInboxView({required this.showHeader});

  final bool showHeader;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // backgroundColor: colorScheme.surface,
      backgroundColor: const Color(0xFFFBFEFC),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.darkTeal,
        onPressed: () {
          final cubit = context.read<ChatInboxCubit>();
          Navigator.push(
            context,
            MaterialPageRoute<void>(
              builder: (_) => NewConversationPage(
                repository: cubit.repository,
                currentUser: cubit.currentUser,
              ),
            ),
          );
        },
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showHeader) ...[
                Text(
                  'Chats',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
              ],
              SearchField(
                hintText: 'Search conversations',
                onChanged: (query) => context.read<ChatInboxCubit>().search(query),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: BlocBuilder<ChatInboxCubit, ChatInboxState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final conversations = state.filteredConversations;
                    if (conversations.isEmpty) {
                      return Center(
                        child: Text(
                          state.query.isEmpty
                              ? 'No conversations yet. Tap + to start one.'
                              : 'No conversations match "${state.query}".',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.only(bottom: 90, top: 4),
                      itemCount: conversations.length,
                      separatorBuilder: (context, index) => Divider(
                        height: 1,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.25),
                      ),
                      itemBuilder: (context, index) {
                        final conversation = conversations[index];
                        final cubit = context.read<ChatInboxCubit>();
                        return ConversationTile(
                          conversation: conversation,
                          currentUser: state.currentUser,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute<void>(
                                builder: (_) => ConversationPage(
                                  repository: cubit.repository,
                                  conversationId: conversation.id,
                                  currentUser: state.currentUser,
                                ),
                              ),
                            );
                          },
                          onMuteToggle: () => cubit.toggleMute(conversation),
                          onDelete: () => cubit.deleteConversation(conversation.id),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
