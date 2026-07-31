import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/caregiver_notifications_dummy_data.dart';
import '../models/caregiver_notification.dart';

part 'caregiver_notifications_state.dart';

class CaregiverNotificationsCubit extends Cubit<CaregiverNotificationsState> {
  CaregiverNotificationsCubit() : super(const CaregiverNotificationsState()) {
    loadNotifications();
  }

  void loadNotifications() {
    emit(state.copyWith(allNotifications: buildNotificationDummyData()));
  }

  void setFilter(NotificationType? type) {
    if (type == null) {
      emit(state.copyWith(clearFilter: true));
    } else {
      emit(state.copyWith(activeFilter: type));
    }
  }
}