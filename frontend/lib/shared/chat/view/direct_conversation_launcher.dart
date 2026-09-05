import 'package:flutter/material.dart';

import '../data/chat_session.dart';
import '../models/chat_participant.dart';
import 'conversation_page.dart';

/// Opens the real, backend-backed thread with [contactName] — the same
/// conversation the Chats tab shows, delivered over the same socket.
///
/// Every "Message" button outside the Chats tab used to build its own
/// `MockChatRepository` thread instead: an in-memory conversation with a
/// UUID id the backend has never heard of. Nothing sent there reached the
/// other person, nothing they sent ever arrived — the mock has no socket,
/// so the thread only changed when *this* device changed it, which is
/// exactly the "chat only updates if I leave and come back" symptom — and
/// a call placed from it rang nobody but the caller, since the server
/// parses `conversation_id` as an integer and silently drops signaling
/// for a conversation it can't resolve.
///
/// The contact is resolved through `GET /chat/contacts` (the people this
/// user is actually allowed to message — accepted bookings and family
/// links) because the dashboards know a caregiver or patient by name,
/// while conversations are keyed by user id.
Future<void> openDirectConversation(
  BuildContext context, {
  required String contactName,
  ChatRole? role,
}) async {
  // Captured before the first await: this returns to a widget that may no
  // longer be mounted, and reading either off `context` afterwards is
  // exactly what `use_build_context_synchronously` guards against.
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.maybeOf(context);

  void report(String message) {
    messenger?.showSnackBar(SnackBar(content: Text(message)));
  }

  try {
    final session = await ChatSession.ensureStarted();
    final contacts = await session.repository.getContacts(session.currentUser);
    final contact = _findContact(contacts, contactName, role);
    if (contact == null) {
      report('$contactName is not available to message yet.');
      return;
    }

    final conversation = await session.repository.createDirectConversation(
      currentUser: session.currentUser,
      other: contact,
    );
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => ConversationPage(
          repository: session.repository,
          conversationId: conversation.id,
          currentUser: session.currentUser,
        ),
      ),
    );
  } catch (_) {
    // No token yet, no network, or the contact list failed to load. The
    // Chats tab is still there — better a message than a dead button.
    report('Could not open the chat. Please try again.');
  }
}

/// Contacts matching [role] are searched first, then everyone, so a role
/// the dashboard guessed wrong costs an exact match rather than the chat.
ChatParticipant? _findContact(
  List<ChatParticipant> contacts,
  String name,
  ChatRole? role,
) {
  final wanted = _normalize(name);
  if (wanted.isEmpty) return null;
  final byRole = role == null
      ? contacts
      : contacts.where((c) => c.role == role).toList();
  return _match(byRole, wanted) ?? _match(contacts, wanted);
}

ChatParticipant? _match(List<ChatParticipant> contacts, String wanted) {
  for (final contact in contacts) {
    if (_normalize(contact.name) == wanted) return contact;
  }
  // Titles and suffixes drift between screens ("Dr. Karim" on a card,
  // "Karim Ahmed" in the directory). One partial match is still
  // unambiguous; several means guessing, so hand back nothing.
  final partial = contacts.where((c) {
    final candidate = _normalize(c.name);
    return candidate.contains(wanted) || wanted.contains(candidate);
  }).toList();
  return partial.length == 1 ? partial.first : null;
}

String _normalize(String value) =>
    value.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
