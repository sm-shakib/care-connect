import 'package:flutter/material.dart';

import 'package:frontend/theme/app_colors.dart';

import '../data/chat_directory.dart';
import '../data/chat_repository.dart';
import '../models/chat_participant.dart';
import '../widgets/member_tile.dart';
import 'conversation_page.dart';

/// Contact picker for starting a new conversation: tap a contact to open
/// (or create) a direct 1:1 chat, or switch to "New group" to select
/// multiple contacts and name a group.
class NewConversationPage extends StatefulWidget {
  const NewConversationPage({super.key, required this.repository, required this.currentUser});

  final ChatRepository repository;
  final ChatParticipant currentUser;

  @override
  State<NewConversationPage> createState() => _NewConversationPageState();
}

class _NewConversationPageState extends State<NewConversationPage> {
  bool _groupMode = false;
  final _selected = <ChatParticipant>{};
  bool _isCreating = false;

  Future<void> _openDirect(ChatParticipant contact) async {
    setState(() => _isCreating = true);
    final conversation = await widget.repository.createDirectConversation(
      currentUser: widget.currentUser,
      other: contact,
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(
          repository: widget.repository,
          conversationId: conversation.id,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  Future<void> _createGroup() async {
    // "Family Group" is this app's naming convention for care-team groups
    // (elder + caregiver + family members) — prefilled but still editable.
    final titleController = TextEditingController(text: 'Family Group');
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Name this group'),
        content: TextField(
          controller: titleController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. "Family Group"'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, titleController.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (title == null || title.isEmpty) return;

    setState(() => _isCreating = true);
    final conversation = await widget.repository.createGroupConversation(
      title: title,
      createdBy: widget.currentUser,
      members: _selected.toList(),
    );
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(
          repository: widget.repository,
          conversationId: conversation.id,
          currentUser: widget.currentUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contacts = ChatDirectory.contactsFor(widget.currentUser);

    return Scaffold(
      appBar: AppBar(
        title: Text(_groupMode ? 'New group' : 'New chat'),
        actions: [
          TextButton(
            onPressed: _isCreating
                ? null
                : () => setState(() {
                      _groupMode = !_groupMode;
                      _selected.clear();
                    }),
            child: Text(
              _groupMode ? 'Cancel' : 'New group',
              style: const TextStyle(color: AppColors.darkTeal, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: _isCreating
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                final isSelected = _selected.contains(contact);
                return MemberTile(
                  participant: contact,
                  subtitle: contact.role.name,
                  selected: isSelected,
                  onTap: () {
                    if (!_groupMode) {
                      _openDirect(contact);
                      return;
                    }
                    setState(() {
                      if (isSelected) {
                        _selected.remove(contact);
                      } else {
                        _selected.add(contact);
                      }
                    });
                  },
                );
              },
            ),
      floatingActionButton: _groupMode && _selected.length >= 2
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.darkTeal,
              onPressed: _createGroup,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text('Create group', style: TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
