import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

import '../data/chat_repository.dart';
import '../models/chat_participant.dart';
import '../models/conversation.dart';
import '../widgets/member_tile.dart';

/// Group details: member list with add/remove management. Only the
/// group's creator can remove other members (or leave); everyone can add
/// new members from their contact directory.
class GroupInfoPage extends StatefulWidget {
  const GroupInfoPage({
    super.key,
    required this.repository,
    required this.conversationId,
    required this.currentUser,
  });

  final ChatRepository repository;
  final String conversationId;
  final ChatParticipant currentUser;

  @override
  State<GroupInfoPage> createState() => _GroupInfoPageState();
}

class _GroupInfoPageState extends State<GroupInfoPage> {
  late Stream<Conversation?> _stream;

  @override
  void initState() {
    super.initState();
    _stream = widget.repository.watchConversation(widget.conversationId);
  }

  Future<void> _addMembers(Conversation conversation) async {
    final currentIds = conversation.participants.map((p) => p.id).toSet();
    final allContacts = await widget.repository.getContacts(widget.currentUser);
    final candidates = allContacts
        .where((p) => !currentIds.contains(p.id))
        .toList();
    if (!mounted) return;

    if (candidates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Everyone in your contacts is already in this group.'),
        ),
      );
      return;
    }

    final selected = <ChatParticipant>{};
    final toAdd = await showModalBottomSheet<List<ChatParticipant>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFBFEFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add members',
                      style: Theme.of(sheetContext).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: candidates.length,
                        itemBuilder: (context, index) {
                          final candidate = candidates[index];
                          final isSelected = selected.contains(candidate);
                          return MemberTile(
                            participant: candidate,
                            selected: isSelected,
                            onTap: () => setSheetState(() {
                              if (isSelected) {
                                selected.remove(candidate);
                              } else {
                                selected.add(candidate);
                              }
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: selected.isEmpty
                            ? null
                            : () => Navigator.pop(
                                sheetContext,
                                selected.toList(),
                              ),
                        child: const Text('Add to group'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (toAdd != null && toAdd.isNotEmpty) {
      await widget.repository.addMembers(widget.conversationId, toAdd);
    }
  }

  Future<void> _removeMember(ChatParticipant member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove member?'),
        content: Text(
          '${member.name} will no longer see this group\'s messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warningRed,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await widget.repository.removeMember(widget.conversationId, member.id);
    }
  }

  Future<void> _leaveGroup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave group?'),
        content: const Text(
          'You will no longer receive messages from this group.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warningRed,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      await widget.repository.removeMember(
        widget.conversationId,
        widget.currentUser.id,
      );
      if (mounted) Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFFBFEFC),
      appBar: AppBar(title: const Text('Group info')),
      body: StreamBuilder<Conversation?>(
        stream: _stream,
        builder: (context, snapshot) {
          final conversation = snapshot.data;
          if (conversation == null)
            return const Center(child: CircularProgressIndicator());

          final isCreator = conversation.createdBy == widget.currentUser.id;
          final members = conversation.participants;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: conversation.avatarColor,
                      child: const Icon(
                        Icons.groups,
                        size: 40,
                        color: AppColors.darkTeal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      conversation.title ?? 'Group chat',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${members.length} member${members.length == 1 ? '' : 's'}',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Members',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  TextButton.icon(
                    onPressed: () => _addMembers(conversation),
                    icon: const Icon(
                      Icons.person_add_alt,
                      color: AppColors.darkTeal,
                    ),
                    label: const Text(
                      'Add',
                      style: TextStyle(color: AppColors.darkTeal),
                    ),
                  ),
                ],
              ),
              for (final member in members)
                MemberTile(
                  participant: member,
                  subtitle: member.id == widget.currentUser.id
                      ? 'You'
                      : member.id == conversation.createdBy
                      ? '${member.role.name} • Group admin'
                      : member.role.name,
                  trailing: (isCreator && member.id != widget.currentUser.id)
                      ? IconButton(
                          icon: Icon(
                            Icons.remove_circle_outline,
                            color: colorScheme.error,
                          ),
                          tooltip: 'Remove member',
                          onPressed: () => _removeMember(member),
                        )
                      : null,
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _leaveGroup,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warningRed,
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Leave group'),
              ),
            ],
          );
        },
      ),
    );
  }
}
