import 'package:flutter/material.dart';

import '../models/chat_participant.dart';

/// Hardcoded participant directory shared by every role's chat surface.
///
/// There is no auth/session layer in this app yet (see `login/`'s dummy
/// cubits), so — same as the rest of the prototype's dummy data — "who am
/// I" and "who can I message" are resolved from a fixed cast of mock
/// people rather than a real backend. Names are deliberately reused from
/// the existing per-role dummy data (`DashboardCubit`'s "Adib" + "Shakib
/// Khan", `elder_dummy_data.dart`'s "Abdul Karim" / "Sarah Jenkins" /
/// "Michael Chen") so a signed-in elderly/caregiver/family screen and its
/// Chats tab agree on who's who. Swap this for a real directory lookup
/// once accounts/sessions exist.
class ChatDirectory {
  ChatDirectory._();

  static const adib = ChatParticipant(
    id: 'user-elder-adib',
    name: 'Adib',
    role: ChatRole.elderly,
    avatarColor: Color(0xFFCCFBF1),
    isOnline: true,
  );

  static const shakibKhan = ChatParticipant(
    id: 'user-caregiver-shakib',
    name: 'Shakib Khan',
    role: ChatRole.caregiver,
    avatarColor: Color(0xFF8FA7FE),
    isOnline: true,
  );

  static const nusratJahan = ChatParticipant(
    id: 'user-family-nusrat',
    name: 'Nusrat Jahan',
    role: ChatRole.family,
    avatarColor: Color(0xFFDCE1FF),
  );

  static const roseDawson = ChatParticipant(
    id: 'user-elder-rose',
    name: 'Rose Dawson',
    role: ChatRole.elderly,
    avatarColor: Color(0xFFCCFBF1),
  );

  static const abdulKarim = ChatParticipant(
    id: 'user-elder-abdul',
    name: 'Abdul Karim',
    role: ChatRole.elderly,
    avatarColor: Color(0xFFCCFBF1),
    isOnline: true,
  );

  static const sarahJenkins = ChatParticipant(
    id: 'user-caregiver-sarah',
    name: 'Sarah Jenkins',
    role: ChatRole.caregiver,
    avatarColor: Color(0xFF8FA7FE),
    isOnline: true,
  );

  static const michaelChen = ChatParticipant(
    id: 'user-caregiver-michael',
    name: 'Michael Chen',
    role: ChatRole.caregiver,
    avatarColor: Color(0xFF8FA7FE),
  );

  static const asifRahman = ChatParticipant(
    id: 'user-family-asif',
    name: 'Asif Rahman',
    role: ChatRole.family,
    avatarColor: Color(0xFFDCE1FF),
    isOnline: true,
  );

  static const ayeshaRahman = ChatParticipant(
    id: 'user-family-ayesha',
    name: 'Ayesha Rahman',
    role: ChatRole.family,
    avatarColor: Color(0xFFDCE1FF),
  );

  static const all = [
    adib,
    shakibKhan,
    nusratJahan,
    roseDawson,
    abdulKarim,
    sarahJenkins,
    michaelChen,
    asifRahman,
    ayeshaRahman,
  ];

  /// The mock "current device user" for each role's Chats tab.
  static ChatParticipant currentUserFor(ChatRole role) {
    switch (role) {
      case ChatRole.elderly:
        return adib;
      case ChatRole.caregiver:
        return shakibKhan;
      case ChatRole.family:
        return asifRahman;
      case ChatRole.admin:
        throw UnsupportedError('Admin accounts do not use the chat module.');
    }
  }

  /// People `currentUser` can start a new conversation with, beyond
  /// whoever is already in one of their existing conversations.
  static List<ChatParticipant> contactsFor(ChatParticipant currentUser) {
    switch (currentUser.id) {
      case 'user-elder-adib':
        return const [shakibKhan, nusratJahan];
      case 'user-caregiver-shakib':
        return const [adib, nusratJahan, roseDawson];
      case 'user-family-asif':
        return const [abdulKarim, sarahJenkins, michaelChen, ayeshaRahman];
      default:
        return all.where((p) => p.id != currentUser.id).toList();
    }
  }

  static ChatParticipant byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => all.first);

  /// Looks up a participant by (case-insensitive) name, falling back to a
  /// synthesized ad-hoc participant when the name doesn't match anyone in
  /// the directory. Used by call sites elsewhere in the app that only
  /// have a free-text name on hand (e.g. a patient/elder name from their
  /// own module's dummy data) rather than a real [ChatParticipant] id —
  /// keeps those "Chat" buttons working without requiring every mock
  /// dataset in the app to be unified.
  static ChatParticipant resolveOrCreateContact(String name, {ChatRole role = ChatRole.elderly}) {
    final trimmed = name.trim();
    for (final participant in all) {
      if (participant.name.toLowerCase() == trimmed.toLowerCase()) return participant;
    }
    final slug = trimmed.toLowerCase().replaceAll(RegExp(r'\s+'), '-');
    return ChatParticipant(id: 'contact-$slug', name: trimmed, role: role);
  }
}
