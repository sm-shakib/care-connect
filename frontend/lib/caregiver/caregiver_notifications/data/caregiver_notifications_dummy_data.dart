import '../models/caregiver_notification.dart';

// TODO: replace with a real repository call / push-notification store.
List<CaregiverNotification> buildNotificationDummyData() {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  return [
    CaregiverNotification(
      id: 'n1',
      type: NotificationType.medicineMissed,
      title: 'Medicine Not Taken: Eleanor Rigby',
      message:
      'Missed 8:00 AM dose of Metoprolol (25mg). Please follow up as soon as possible.',
      timestamp: today.add(const Duration(hours: 8, minutes: 45)),
      patientName: 'Eleanor Rigby',
    ),
    CaregiverNotification(
      id: 'n2',
      type: NotificationType.medicineTaken,
      title: 'Medicine Taken: Arthur Miller',
      message: 'Lisinopril (10mg) was marked as taken, on schedule.',
      timestamp: today.add(const Duration(hours: 13)),
      patientName: 'Arthur Miller',
    ),
    CaregiverNotification(
      id: 'n3',
      type: NotificationType.careReminderMet,
      title: 'Hydration Goal Met: Rose Dawson',
      message: 'Rose reached her 8-glass water intake goal for the day.',
      timestamp: today.add(const Duration(hours: 15, minutes: 30)),
      patientName: 'Rose Dawson',
    ),
    CaregiverNotification(
      id: 'n4',
      type: NotificationType.paymentReceived,
      title: 'Payment Received',
      message: 'Payment received from Michael Rigby (family member).',
      timestamp: today.add(const Duration(hours: 17)),
      amount: 850.00,
    ),
    CaregiverNotification(
      id: 'n5',
      type: NotificationType.careReminderMet,
      title: 'Physical Therapy Completed: John Watson',
      message: 'John completed his scheduled physiotherapy session.',
      timestamp: yesterday.add(const Duration(hours: 14)),
      patientName: 'John Watson',
    ),
    CaregiverNotification(
      id: 'n6',
      type: NotificationType.medicineMissed,
      title: 'Medicine Not Taken: John Watson',
      message: 'Missed 8:00 PM dose of Aspirin (75mg).',
      timestamp: yesterday.add(const Duration(hours: 20, minutes: 10)),
      patientName: 'John Watson',
    ),
    CaregiverNotification(
      id: 'n7',
      type: NotificationType.paymentReceived,
      title: 'Payment Received',
      message: 'Payment received from CareConnect (weekly payout).',
      timestamp: yesterday.add(const Duration(hours: 9)),
      amount: 420.00,
    ),
  ];
}