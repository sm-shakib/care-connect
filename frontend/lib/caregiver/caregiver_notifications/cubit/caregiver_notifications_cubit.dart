import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/network/api_client.dart';

import '../models/caregiver_notification.dart';

part 'caregiver_notifications_state.dart';

class CaregiverNotificationsCubit extends Cubit<CaregiverNotificationsState> {
  CaregiverNotificationsCubit({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(),
        super(const CaregiverNotificationsState()) {
    loadNotifications();
  }

  final ApiClient _apiClient;

  Future<void> loadNotifications() async {
    emit(state.copyWith(status: CaregiverNotificationsStatus.loading));
    try {
      final response = await _apiClient.get<List<dynamic>>('/notifications/');
      final notifications = (response.data ?? const <dynamic>[])
          .map(
            (raw) => CaregiverNotification.fromJson(
              Map<String, dynamic>.from(raw as Map),
            ),
          )
          .toList();
      emit(
        state.copyWith(
          status: CaregiverNotificationsStatus.success,
          allNotifications: notifications,
        ),
      );
      // Opening this page is itself the "read" action — the same way
      // opening a chat thread clears its unread badge.
      unawaited(markAllAsRead());
    } catch (_) {
      emit(
        state.copyWith(
          status: CaregiverNotificationsStatus.failure,
          errorMessage: 'Could not load notifications.',
        ),
      );
    }
  }

  /// Backs pull-to-refresh — a plain alias so the view doesn't need to
  /// know [loadNotifications] also drives the initial load.
  Future<void> refresh() => loadNotifications();

  /// Marks every notification read in one call, updating the list
  /// immediately and syncing to the backend in the background — mirrors
  /// [markAsRead]'s optimistic-update/best-effort-sync shape.
  Future<void> markAllAsRead() async {
    if (state.allNotifications.every((n) => n.isRead)) return;

    final updated = [
      for (final n in state.allNotifications) n.copyWith(isRead: true),
    ];
    emit(state.copyWith(allNotifications: updated));

    try {
      await _apiClient.put<void>('/notifications/read-all');
    } catch (_) {
      // Best-effort: same fallback as markAsRead — a failed sync just
      // means it may show unread again after the next refresh.
    }
  }

  void setFilter(String? type) {
    if (type == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(activeFilter: type));
    }
  }

  /// Marks [notificationId] read, updating the list immediately (an
  /// unread dot that doesn't clear the instant it's tapped reads as
  /// broken) and syncing to the backend in the background.
  Future<void> markAsRead(String notificationId) async {
    final index =
        state.allNotifications.indexWhere((n) => n.id == notificationId);
    if (index == -1 || state.allNotifications[index].isRead) return;

    final updated = [
      for (final n in state.allNotifications)
        if (n.id == notificationId) n.copyWith(isRead: true) else n,
    ];
    emit(state.copyWith(allNotifications: updated));

    try {
      await _apiClient.put<void>('/notifications/$notificationId/read');
    } catch (_) {
      // Best-effort: the list already reflects "read" locally; a failed
      // sync just means it may show unread again after the next refresh.
    }
  }
}
